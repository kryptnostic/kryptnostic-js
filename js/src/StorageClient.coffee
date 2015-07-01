define('soteria.storage-client', [
  'require'
  'jquery'
  'soteria.crypto-service-loader'
  'soteria.kryptnostic-object'
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

      #   for ( EncryptableBlock input : obj.getBody().getEncryptedData() ) {
      #       try {
      #           objectApi.updateObject( objectId, input );
      #       } catch ( ResourceNotFoundException | ResourceNotLockedException | BadRequestException e ) {
      #           logger.error( "Failed to uploaded block. Should probably add a retry here!" );
      #       }
      #       logger.info( "Object block upload completed for object {} and block {}", objectId, input.getIndex() );
      #   }

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
      .then (id) ->
        kryptnosticObject = KryptnosticObject.createFromDecrypted({id, body})

        if kryptnosticObject.isEncrypted()
          throw new Error('expected object to be in a decrypted state')

        console.info('[StorageClient] object ' + JSON.stringify(kryptnosticObject))

        cryptoServiceLoader = new CryptoServiceLoader('demo') #TODO

        console.info('[StorageClient] made crypto service loader')

        cryptoServiceLoader.getObjectCryptoService(id)
        .then (cryptoService) ->
          console.info('[StorageClient] encrypting object')
          encryptedObject = kryptnosticObject.encrypt(cryptoService)
          console.info('[StorageClient] encrypted object ' + JSON.stringify(encryptedObject))
          submitObjectBlocks(encryptedObject)

  return StorageClient
)
