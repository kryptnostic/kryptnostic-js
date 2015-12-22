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

  class ObjectApi

    wrapCredentials : (request, credentials) ->
      return Requests.wrapCredentials(request, credentials)

    getObject : (id) ->
      throw new Error('ObjectApi:getObject() is not implemented')

    getObjectIds : ->
      throw new Error('ObjectApi:getObjectIds() is not implemented')

    getVersionedObjectKey: (objectId) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'GET'
            url    : objectIdUrl(objectId)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.v2.storage.models.VersionedObjectKey
          return axiosResponse.data;
        else
          return null

    getObjectMetadata: (objectId) ->
      validateId(objectId)
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'GET'
            url    : objectMetadataUrl(objectId)
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
            method  : 'POST'
            url     : objectUrl()
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

    getObjectAsBlockCiphertext: (versionedObjectKey) ->
      # TODO: validate versionedObjectKey
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'GET'
            url    : objectVersionUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
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

    setObjectFromBlockCiphertext: (versionedObjectKey, blockCiphertext) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            method  : 'PUT'
            url     : objectVersionUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
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
        method  : 'POST'
        url     : objectUrl() + '/' + id
        headers : _.clone(DEFAULT_HEADER)
        data    : JSON.stringify(encryptableBlock)
      })))
      .then (response) ->
        logger.debug('submitted block', { id })

    deleteObject : (objectId) ->
      validateId(objectId)
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'DELETE'
            url    : objectIdUrl(objectId)
          })
        )
      )
      .then (axiosResponse) ->
        logger.debug('deleted object', { objectId })

  return ObjectApi
