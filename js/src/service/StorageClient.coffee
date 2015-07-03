define 'soteria.storage-client', [
  'require'
  'jquery'
  'soteria.crypto-service-loader'
  'soteria.kryptnostic-object'
  'soteria.logger'
  'soteria.object-api'
  'soteria.pending-object-request'
], (require) ->
  'use strict'

  jquery               = require 'jquery'
  SecurityUtils        = require 'soteria.security-utils'
  KryptnosticObject    = require 'soteria.kryptnostic-object'
  PendingObjectRequest = require 'soteria.pending-object-request'
  CryptoServiceLoader  = require 'soteria.crypto-service-loader'
  ObjectApi            = require 'soteria.object-api'
  Logger               = require 'soteria.logger'

  logger = Logger.get('StorageClient')

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  # Author: rbuckheit
  #
  class StorageClient

    constructor : ->
      @objectApi = new ObjectApi()

    getObjectIds : ->
      return @objectApi.getObjectIds()

    getObject : (id) ->
      return @objectApi.getObject(id)

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

    uploadObject : (storageRequest) ->
      storageRequest.validate()

      {body, objectId} = storageRequest
      pendingPromise   = undefined

      if objectId?
        pendingPromise = @objectApi.createPendingObjectFromExisting(objectId)
      else
        pendingOpts    = _.pick(storageRequest, 'type', 'parentObjectId')
        pendingRequest = new PendingObjectRequest(pendingOpts)
        pendingPromise = @objectApi.createPendingObject(pendingRequest)

      pendingPromise
      .then (id) =>
        logger.info('pending id', id)

        kryptnosticObject = KryptnosticObject.createFromDecrypted({id, body})

        if kryptnosticObject.isEncrypted()
          throw new Error('expected object to be in a decrypted state')

        logger.info('object', kryptnosticObject)

        cryptoServiceLoader = new CryptoServiceLoader('demo') #TODO

        logger.info('made crypto service loader')

        cryptoServiceLoader.getObjectCryptoService(id)
        .then (cryptoService) =>
          encryptedObject = kryptnosticObject.encrypt(cryptoService)
          logger.info('encrypted object', encryptedObject)
          @submitObjectBlocks(encryptedObject)
        .then ->
          return id

  return StorageClient
