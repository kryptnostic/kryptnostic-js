define('soteria.storage-client', [
  'require'
  'jquery'
  'soteria.security-utils'
  'soteria.kryptnostic-object'
  'soteria.pending-object-request'
], (require) ->
  'use strict'

  jquery               = require 'jquery'
  SecurityUtils        = require 'soteria.security-utils'
  KryptnosticObject    = require 'soteria.kryptnostic-object'
  PendingObjectRequest = require 'soteria.pending-object-request'

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

    _createPendingObject : (pendingRequest) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url         : OBJECT_URL + '/'
        type        : 'PUT'
        contentType : 'application/json',
        data        : JSON.stringify(pendingRequest)
      }))
      .then (response) ->
        console.info('[StorageClient] created pending ' + JSON.stringify(response));
        return response.data.id

    _createPendingObjectFromExisting : (id) ->
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
        pendingPromise = @_createPendingObjectFromExisting(objectId)
      else
        pendingOpts    = _.pick(storageRequest, 'type', 'parentObjectId')
        pendingRequest = new PendingObjectRequest(pendingOpts)
        pendingPromise = @_createPendingObject(pendingRequest)

      pendingPromise
      .then (id) ->
        kryptnosticObject = KryptnosticObject.createFromDecrypted({id, body})

        if kryptnosticObject.isEncrypted()
          throw new Error('cannot upload object unless in decrypted state')

        console.info('would upload object' + JSON.stringify(kryptnosticObject))


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
