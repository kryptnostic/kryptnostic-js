define('soteria.storage-client', [
  'require'
  'jquery'
  'soteria.security-utils'
  'soteria.kryptnostic-object'
  'soteria.pending-object-request'
  'soteria.crypto-service-loader'
], (require) ->
  'use strict'

  jquery               = require 'jquery'
  SecurityUtils        = require 'soteria.security-utils'
  KryptnosticObject    = require 'soteria.kryptnostic-object'
  PendingObjectRequest = require 'soteria.pending-object-request'
  CryptoServiceLoader  = require 'soteria.crypto-service-loader'

  # TODO: define a configurable URL provider.
  OBJECT_URL    = 'http://localhost:8081/v1/object'

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  # Author: rbuckheit
  #
  class StorageClient

    getObjectIds : (id) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL
        type : 'GET'
      }))
      .then (data) ->
        return data.data

    getObject : (id) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id
        type : 'GET'
      }))
      .then (data) ->
        return KryptnosticObject.createFromEncrypted(data);

    createPendingObject : (pendingRequest) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url         : OBJECT_URL + '/'
        type        : 'PUT'
        contentType : 'application/json',
        data        : JSON.stringify(pendingRequest)
      }))
      .then (response) ->
        console.info('[StorageClient] created pending ' + JSON.stringify(response));
        return response.data.id

    createPendingObjectFromExisting : (id) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id
        type : 'PUT'
      }))
      .then (response) ->
        console.info('[StorageClient] created pending from existing ' + JSON.stringify(response));
        return response.data.id

    uploadObject : (storageRequest) ->
      storageRequest.validate()

      {body, objectId} = storageRequest
      pendingPromise   = undefined

      if objectId?
        pendingPromise = @createPendingObjectFromExisting(objectId)
      else
        pendingOpts    = _.pick(storageRequest, 'type', 'parentObjectId')
        pendingRequest = new PendingObjectRequest(pendingOpts)
        pendingPromise = @createPendingObject(pendingRequest)

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

        # Preconditions.checkArgument( !obj.getBody().isEncrypted() );
        # String objId = obj.getMetadata().getId();
        # // upload the object blocks
        # if ( req.isStoreable() ) {
        #     storeObject( obj );
        # }

        # EncryptedSearchSharingKey sharingKey = setupSharing(obj);

        # if ( req.isSearchable() ) {
        #     makeObjectSearchable( obj, sharingKey );
        # }

        # return objId;

  return StorageClient
)
