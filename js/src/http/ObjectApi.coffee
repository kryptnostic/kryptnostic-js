define 'kryptnostic.object-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.block-ciphertext'
  'kryptnostic.configuration'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.object-metadata'
  'kryptnostic.validators'
  'kryptnostic.object-tree-load-request'
], (require) ->

  axios                 = require 'axios'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'
  Requests              = require 'kryptnostic.requests'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  Logger                = require 'kryptnostic.logger'
  Config                = require 'kryptnostic.configuration'
  Promise               = require 'bluebird'
  ObjectMetadata        = require 'kryptnostic.object-metadata'
  ObjectMetadataTree    = require 'kryptnostic.object-metadata-tree'
  ObjectTreeLoadRequest = require 'kryptnostic.object-tree-load-request'
  validators            = require 'kryptnostic.validators'

  { validateId, validateObjectType } = validators

  objectUrl         = -> Config.get('servicesUrlV2') + '/object'
  objectIdUrl       = (objectId) -> objectUrl() + '/id/' + objectId
  objectMetadataUrl = (objectId) -> objectIdUrl(objectId) + '/metadata'
  objectVersionUrl  = (objectId, objectVersion) -> objectIdUrl(objectId) + '/' + objectVersion
  objectLevelsUrl   = -> objectUrl() + '/levels'

  logger = Logger.get('ObjectApi')

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  #
  # HTTP calls for interacting with the /object endpoint of Kryptnostic Services.
  # Author: rbuckheit
  #
  class ObjectApi

    wrapCredentials : (request, credentials) ->
      return Requests.wrapCredentials(request, credentials)

    # get all object ids accessible to the user
    getObjectIds : ->
      Promise.resolve(axios(@wrapCredentials({
        url    : objectUrl()
        method : 'GET'
      })))
      .then (response) ->
        objectIds = response.data.data
        return objectIds

    # load a kryptnosticObject in encrypted form
    getObject : (id) ->
      validateId(id)
      Promise.resolve(
        axios(
          @wrapCredentials({
            url    : objectIdUrl(id)
            method : 'GET'
          })
        )
      )
      .then (response) ->
        raw = response.data
        return KryptnosticObject.createFromEncrypted(raw)

    getVersionedObjectKey: (objectId) ->
      # TODO: validate versionedObjectKey
      Promise.resolve(
        axios(
          @wrapCredentials({
            url    : objectIdUrl(objectId)
            method : 'GET'
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.v2.storage.models.VersionedObjectKey
          return axiosResponse.data;
        else
          return null

    getObjectAsBlockCiphertext: (versionedObjectKey) ->
      # TODO: validate versionedObjectKey
      Promise.resolve(
        axios(
          @wrapCredentials({
            url    : objectVersionUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
            method : 'GET'
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.kodex.v1.crypto.ciphers.BlockCiphertext
          try
            return new BlockCiphertext(axiosResponse.data)
          catch e
            return null
        else
          return null

    # load object metadata only without contents
    getObjectMetadata: (objectId) ->
      validateId(objectId)
      Promise.resolve(
        axios(
          @wrapCredentials({
            url    : objectMetadataUrl(objectId)
            method : 'GET'
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.v2.storage.models.ObjectMetadata
          return new ObjectMetadata(axiosResponse.data)
        else
          return null

    getObjectsByTypeAndLoadLevel: (objectIds, typeLoadLevels, loadDepth) ->

      objectTreeLoadRequest = new ObjectTreeLoadRequest({
        objectIds  : objectIds
        loadLevels : typeLoadLevels
        depth      : loadDepth
      })

      Promise.resolve(
        axios(
          @wrapCredentials({
            method  : 'POST'
            url     : objectLevelsUrl()
            headers : _.clone(DEFAULT_HEADER)
            data    : JSON.stringify(objectTreeLoadRequest)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Map<java.util.UUID, com.kryptnostic.v2.storage.models.ObjectMetadataEncryptedNode>
          # return new ObjectMetadataTree(axiosResponse.data)
          return axiosResponse.data
        else
          return null

    createObject: (createObjectRequest) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            url     : objectUrl()
            method  : 'POST'
            headers : _.clone(DEFAULT_HEADER)
            data    : JSON.stringify(createObjectRequest)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.v2.storage.models.VersionedObjectKey
          return axiosResponse.data
        else
          return null

    setObjectFromBlockCiphertext: (versionedObjectKey, blockCiphertext) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            url     : objectVersionUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
            method  : 'PUT'
            headers : _.clone(DEFAULT_HEADER)
            data    : JSON.stringify(blockCiphertext)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          return axiosResponse.data
        else
          return null

    # adds an encrypted block to a pending object
    updateObject : (id, encryptableBlock) ->
      validateId(id)

      Promise.resolve(axios(@wrapCredentials({
        url     : objectUrl() + '/' + id
        method  : 'POST'
        headers : _.clone(DEFAULT_HEADER)
        data    : JSON.stringify(encryptableBlock)
      })))
      .then (response) ->
        logger.debug('submitted block', { id })

    # deletes an object
    deleteObject : (id) ->
      validateId(id)

      Promise.resolve(axios(@wrapCredentials({
        url    : objectUrl() + '/' + id
        method : 'DELETE'
      })))
      .then (response) ->
        logger.debug('deleted object', { id })

  return ObjectApi
