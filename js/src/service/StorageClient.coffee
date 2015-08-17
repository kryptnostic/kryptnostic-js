define 'kryptnostic.storage-client', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.validators'
  'kryptnostic.object-api'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.pending-object-request'
  'kryptnostic.search-indexing-service'
], (require) ->
  'use strict'

  Promise               = require 'bluebird'
  validators            = require 'kryptnostic.validators'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  PendingObjectRequest  = require 'kryptnostic.pending-object-request'
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  ObjectApi             = require 'kryptnostic.object-api'
  Logger                = require 'kryptnostic.logger'
  SearchIndexingService = require 'kryptnostic.search-indexing-service'

  logger = Logger.get('StorageClient')

  { validateId, validateNonEmptyString } = validators

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  # Author: rbuckheit
  #
  class StorageClient

    constructor : ->
      @objectApi             = new ObjectApi()
      @cryptoServiceLoader   = new CryptoServiceLoader()
      @searchIndexingService = new SearchIndexingService()

    getObjectIds : ->
      return @objectApi.getObjectIds()

    getObject : (id) ->
      return @objectApi.getObject(id)

    getObjectIdsByType : (type) ->
      return @objectApi.getObjectIdsByType(type)

    getObjectMetadata : (id) ->
      return @objectApi.getObjectMetadata(id)

    deleteObject : (id) ->
      return @objectApi.deleteObject(id)

    appendObject : (id, body) ->
      Promise.resolve()
      .then ->
        validateId(id)
        validateNonEmptyString(body)
      .then =>
        @objectApi.createPendingObjectFromExisting(id)
      .then =>
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss : false })
      .then (cryptoService) =>
        @encrypt({ id, body, cryptoService })
      .then (encrypted) =>
        @submitObjectBlocks(encrypted)
      .then ->
        return id

    uploadObject : (storageRequest) ->
      { id, sharingKey } = {}

      Promise.resolve()
      .then ->
        storageRequest.validate()
      .then =>
        @createPending(storageRequest)
      .then (_id) =>
        id = _id
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss : true })
      .then (cryptoService) =>
        { body } = storageRequest
        @encrypt({ id, body, cryptoService })
      .then (encrypted) =>
        @submitObjectBlocks(encrypted)
      .then =>
        @searchIndexingService.submit({ id, storageRequest })
      .then ->
        return id

    encrypt : ({ id, body, cryptoService }) ->
      kryptnosticObject = KryptnosticObject.createFromDecrypted({ id, body })
      return kryptnosticObject.encrypt(cryptoService)

    createPending : (storageRequest = {}) ->
      if storageRequest.objectId?
        return @objectApi.createPendingObjectFromExisting(objectId)
      else
        { type, parentObjectId } = storageRequest
        pendingRequest = new PendingObjectRequest { type, parentObjectId }
        return @objectApi.createPendingObject(pendingRequest)

    submitObjectBlocks : (kryptnosticObject) ->
      Promise.resolve()
      .then =>
        kryptnosticObject.validateEncrypted()

        objectId        = kryptnosticObject.metadata.id
        encryptedBlocks = kryptnosticObject.body.data

        Promise.reduce(encryptedBlocks, (chain, nextEncryptableBlock) =>
          return Promise.resolve(chain)
            .then => @objectApi.updateObject(objectId, nextEncryptableBlock)
        , Promise.resolve())

  return StorageClient
