# coffeelint: disable=cyclomatic_complexity

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
  Logger                = require 'kryptnostic.logger'
  Config                = require 'kryptnostic.configuration'
  Promise               = require 'bluebird'
  ObjectMetadata        = require 'kryptnostic.object-metadata'
  ObjectMetadataTree    = require 'kryptnostic.object-metadata-tree'
  ObjectTreeLoadRequest = require 'kryptnostic.object-tree-load-request'
  Validators            = require 'kryptnostic.validators'

  {
    validateId,
    validateUuid,
    validateUuids
  } = Validators

  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  logger = Logger.get('ObjectApi')

  objectUrl         = -> Config.get('servicesUrlV2') + '/object'
  objectsUrl        = -> objectUrl() + '/bulk'
  objectIdUrl       = (objectId) -> objectUrl() + '/id/' + objectId
  latestObjectIdUrl = (objectId) -> objectUrl() + '/latest/id/' + objectId
  objectMetadataUrl = (objectId) -> objectUrl() + '/objectmetadata/id/' + objectId
  objectVersionUrl  = (objectId, objectVersion) -> objectIdUrl(objectId) + '/' + objectVersion
  objectLevelsUrl   = -> objectUrl() + '/levels'
  indexSegmentUrl   = -> objectUrl() + '/index-segment'

  class ObjectApi

    getObject: (objectId) ->

      #
      # rethink this API. what makes more sense, a bulk GET or a regular single object GET?
      #

      if not validateUuid(objectId)
        return Promise.resolve(null)

      Promise.resolve(
        @getObjects([objectId])
      )
      .then (objects) ->
        return objects[objectId]

    getObjects: (objectIds) ->

      if not validateUuids(objectIds)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : objectsUrl()
            data    : JSON.stringify(objectIds)
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Map<java.util.UUID, com.kryptnostic.kodex.v1.crypto.ciphers.BlockCiphertext>
          return _.mapValues(axiosResponse.data, (blockCiphertext) ->
            try
              return new BlockCiphertext(blockCiphertext)
            catch e
              return null
          )
        else
          return null

    getLatestVersionedObjectKey: (objectId) ->

      if not validateUuid(objectId)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method : 'GET'
            url    : latestObjectIdUrl(objectId)
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

      if not validateUuid(objectId)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
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

    getObjectsByTypeAndLoadLevel: (objectIds, typeLoadLevels, loadDepth, createdAfter) ->

      objectTreeLoadRequest = new ObjectTreeLoadRequest({
        objectIds    : objectIds
        loadLevels   : typeLoadLevels
        depth        : loadDepth,
        createdAfter : createdAfter
      })

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : objectLevelsUrl()
            data    : JSON.stringify(objectTreeLoadRequest)
            headers : DEFAULT_HEADERS
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
          Requests.wrapCredentials({
            method  : 'POST'
            url     : objectUrl()
            data    : JSON.stringify(createObjectRequest)
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.v2.storage.models.VersionedObjectKey
          return axiosResponse.data
        else
          return null

    createIndexSegment: (createIndexSegmentRequest) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : indexSegmentUrl()
            data    : JSON.stringify(createIndexSegmentRequest)
            headers : DEFAULT_HEADERS
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
      Requests.getBlockCiphertextFromUrl(
        objectVersionUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
      )

    setObjectFromBlockCiphertext: (versionedObjectKey, blockCiphertext) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'PUT'
            url     : objectVersionUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
            data    : JSON.stringify(blockCiphertext)
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          return axiosResponse.data
        else
          return null

    deleteObjectTrees: (objectIds) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'DELETE'
            url     : objectUrl()
            data    : JSON.stringify(objectIds)
            headers : DEFAULT_HEADERS
          })
        )
      )

  return ObjectApi
