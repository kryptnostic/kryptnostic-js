define 'kryptnostic.storage-client', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.validators'
  'kryptnostic.object-api'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.object-utils'
  'kryptnostic.pending-object-request'
  'kryptnostic.search-indexing-service'
], (require) ->
  'use strict'

  # libraries
  Promise = require 'bluebird'

  # kryptnostic
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  ObjectApi             = require 'kryptnostic.object-api'
  PendingObjectRequest  = require 'kryptnostic.pending-object-request'
  SearchIndexingService = require 'kryptnostic.search-indexing-service'

  # utils
  Logger      = require 'kryptnostic.logger'
  ObjectUtils = require 'kryptnostic.object-utils'
  validators  = require 'kryptnostic.validators'

  { validateId, validateNonEmptyString } = validators

  logger = Logger.get('StorageClient')

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  #
  class StorageClient

    constructor : ->
      logger.info 'storage client created'
      @objectApi             = new ObjectApi()
      @cryptoServiceLoader   = CryptoServiceLoader.get()
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

    uploadObject : (storageRequest, objectSearchPair) ->
      { objectIdPair } = {}

      Promise.resolve()
      .then ->
        storageRequest.validate()
      .then =>
        @createPending(storageRequest)
      .then (ids) =>
        objectIdPair = ids
        @cryptoServiceLoader.getObjectCryptoService(
          objectIdPair.parentObjectId,
          { expectMiss : true }
        )
      .then (cryptoService) =>
        { body } = storageRequest
        objectId = objectIdPair.objectId
        @encrypt({ objectId, body, cryptoService })
      .then (encrypted) =>
        @submitObjectBlocks(encrypted)
      .then =>
        @searchIndexingService.submit({ storageRequest, objectIdPair, objectSearchPair })
      .then (objectSearchPair) ->
        return {
          objectIdPair     : objectIdPair,
          objectSearchPair : objectSearchPair
        }

    encrypt : ({ objectId, body, cryptoService }) ->
      kryptnosticObject = KryptnosticObject.createFromDecrypted({
        id: objectId,
        body: body
      })
      return kryptnosticObject.encrypt(cryptoService)

    createPending : (storageRequest = {}) ->
      if storageRequest.objectId?
        return @objectApi.createPendingObjectFromExisting(objectId)
      else
        { type, parentObjectId } = storageRequest
        pendingRequest = new PendingObjectRequest { type, parentObjectId }
        Promise.resolve()
        .then =>
          @objectApi.createPendingObject(pendingRequest)
        .then (objectId) ->
          return {
            objectId: objectId,
            parentObjectId: ObjectUtils.childIdToParent(objectId)
          }

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
