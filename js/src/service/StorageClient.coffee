define 'kryptnostic.storage-client', [
  'require'
  'jquery'
  'kryptnostic.logger'
  'kryptnostic.object-api'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.pending-object-request'
], (require) ->
  'use strict'

  jquery               = require 'jquery'
  KryptnosticObject    = require 'kryptnostic.kryptnostic-object'
  PendingObjectRequest = require 'kryptnostic.pending-object-request'
  CryptoServiceLoader  = require 'kryptnostic.crypto-service-loader'
  ObjectApi            = require 'kryptnostic.object-api'
  Logger               = require 'kryptnostic.logger'

  logger = Logger.get('StorageClient')

  validateId = (id) ->
    unless _.isString(id) and not _.isEmpty(id)
      throw new Error 'must specify a string id'

  validateBody = (body) ->
    unless _.isString(body) and not _.isEmpty(body)
      throw new Error 'object body cannot be empty!'

  validateDecrypted = (kryptnosticObject) ->
    if kryptnosticObject.isEncrypted()
      throw new Error 'expected object to be in decrypted state'

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  # Author: rbuckheit
  #
  class StorageClient

    constructor : ->
      @objectApi           = new ObjectApi()
      @cryptoServiceLoader = new CryptoServiceLoader()

    getObjectIds : ->
      return @objectApi.getObjectIds()

    getObject : (id) ->
      return @objectApi.getObject(id)

    getObjectIdsByType : (type) ->
      return @objectApi.getObjectIdsByType(type)

    getObjectMetadata : (id) ->
      return @objectApi.getObjectMetadata(id)

    submitObjectBlocks : (kryptnosticObject) ->
      unless kryptnosticObject.isEncrypted()
        throw new Error('cannot submit blocks for an unencrypted object')

      objectId = kryptnosticObject.metadata.id
      deferred = new jquery.Deferred()
      promise  = deferred.promise()

      kryptnosticObject.body.data.forEach (encryptableBlock) =>
        promise = promise.then =>
          @objectApi.updateObject(objectId, encryptableBlock)

      deferred.resolve()
      return promise

    deleteObject : (id) ->
      Promise.resolve()
      .then =>
        validateId(id)
        return @objectApi.deleteObject(id)

    appendObject : (id, body) ->
      Promise.resolve()
      .then ->
        validateId(id)
        validateBody(body)
      .then =>
        @objectApi.createPendingObjectFromExisting(id)
      .then =>
        kryptnosticObject = KryptnosticObject.createFromDecrypted({ id, body })
        validateDecrypted(kryptnosticObject)

        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss: false })
        .then (cryptoService) =>
          encrypted = kryptnosticObject.encrypt(cryptoService)
          @submitObjectBlocks(encrypted)
        .then ->
          return id

    uploadObject : (storageRequest) ->
      storageRequest.validate()

      { body, objectId } = storageRequest
      pendingPromise     = undefined

      if objectId?
        pendingPromise = @objectApi.createPendingObjectFromExisting(objectId)
      else
        pendingOpts    = _.pick(storageRequest, 'type', 'parentObjectId')
        pendingRequest = new PendingObjectRequest(pendingOpts)
        pendingPromise = @objectApi.createPendingObject(pendingRequest)

      pendingPromise
      .then (id) =>
        kryptnosticObject = KryptnosticObject.createFromDecrypted({ id, body })
        validateDecrypted(kryptnosticObject)

        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss: true })
        .then (cryptoService) =>
          encrypted = kryptnosticObject.encrypt(cryptoService)
          @submitObjectBlocks(encrypted)
        .then ->
          return id

  return StorageClient
