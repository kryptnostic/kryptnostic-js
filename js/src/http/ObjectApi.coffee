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
  'kryptnostic.object-tree-response'
  'kryptnostic.object-tree-paged-response'
  'kryptnostic.paging-direction'
], (require) ->

  axios                 = require 'axios'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'
  Requests              = require 'kryptnostic.requests'
  Logger                = require 'kryptnostic.logger'
  Config                = require 'kryptnostic.configuration'
  Promise               = require 'bluebird'
  ObjectMetadata        = require 'kryptnostic.object-metadata'
  Validators            = require 'kryptnostic.validators'
  ObjectTreeResponse    = require 'kryptnostic.object-tree-response'
  ObjectTreePagedResponse = require 'kryptnostic.object-tree-paged-response'
  PagingDirection       = require 'kryptnostic.paging-direction'

  {
    validateId,
    validateUuid,
    validateUuids,
    validateVersionedObjectKey
  } = Validators

  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  logger = Logger.get('ObjectApi')

  objectUrl = -> Config.get('servicesUrl') + '/object'
  objectCdnUrl = -> Config.get('servicesCdnUrl') + '/object'

  objectIdUrl = (objectId) -> objectUrl() + '/id/' + objectId
  objectIdCdnUrl = (objectId) -> objectCdnUrl() + '/id/' + objectId

  objectVersionUrl = (objectId, objectVersion) -> objectIdUrl(objectId) + '/' + objectVersion
  objectVersionCdnUrl  = (objectId, objectVersion) -> objectIdCdnUrl(objectId) + '/' + objectVersion

  bulkObjectsUrl = -> objectUrl() + '/bulk'
  latestObjectIdUrl = (objectId) -> objectUrl() + '/latest/id/' + objectId
  objectMetadataUrl = (objectId) -> objectUrl() + '/objectmetadata/id/' + objectId

  objectLevelsUrl = -> objectUrl() + '/levels'

  objectTreeInitialPageUrl = (rootObjectKey, pageSize) ->
    objectLevelsUrl() +
      '/' + pageSize +
      '/' + rootObjectKey.objectId + '/' + rootObjectKey.objectVersion

  objectTreePrevPageUrl = (rootObjectKey, lastChildObjectKey, pageSize) ->
    objectLevelsUrl() +
      '/prev/' + pageSize +
      '/' + rootObjectKey.objectId + '/' + rootObjectKey.objectVersion +
      '/' + lastChildObjectKey.objectId + '/' + lastChildObjectKey.objectVersion

  objectTreeNextPageUrl = (rootObjectKey, lastChildObjectKey, pageSize) ->
    objectLevelsUrl() +
      '/next/' + pageSize +
      '/' + rootObjectKey.objectId + '/' + rootObjectKey.objectVersion +
      '/' + lastChildObjectKey.objectId + '/' + lastChildObjectKey.objectVersion

  bulkIndexSegmentsUrl = (objectId, objectVersion) ->
    objectVersionUrl(objectId, objectVersion) + '/index-segments'

  class ObjectApi

    getObjects: (objectIds) ->

      if not validateUuids(objectIds)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : bulkObjectsUrl()
            data    : JSON.stringify(objectIds)
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
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
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == com.kryptnostic.v2.storage.models.VersionedObjectKey
          if validateVersionedObjectKey(axiosResponse.data)
            return axiosResponse.data
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
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == com.kryptnostic.v2.storage.models.ObjectMetadata
          return new ObjectMetadata(axiosResponse.data)
        else
          return null

    getObjectTreeByTypeAndLoadLevel: (objectTreeRequest) ->

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : objectLevelsUrl()
            data    : objectTreeRequest.getRequestData()
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == Map<java.util.UUID, com.kryptnostic.v2.storage.models.ObjectMetadataEncryptedNode>
          objectId = objectTreeRequest.rootObjectKey.objectId
          objectMetadataTree = axiosResponse.data[objectId]
          objectTreeResponse = new ObjectTreeResponse({
            objectMetadataTree
          })
          return objectTreeResponse
        else
          return null

    getObjectTreeByTypeAndLoadLevelPaged: (objectTreePagedRequest) ->

      if PagingDirection.BACKWARDS is objectTreePagedRequest.pagingDirection
        objectTreeRequestUrl = objectTreePrevPageUrl(
          objectTreePagedRequest.rootObjectKey,
          objectTreePagedRequest.lastChildObjectKey,
          objectTreePagedRequest.pageSize
        )
      else if PagingDirection.FORWARDS is objectTreePagedRequest.pagingDirection
        objectTreeRequestUrl = objectTreeNextPageUrl(
          objectTreePagedRequest.rootObjectKey,
          objectTreePagedRequest.lastChildObjectKey,
          objectTreePagedRequest.pageSize
        )
      else
        objectTreeRequestUrl = objectTreeInitialPageUrl(
          objectTreePagedRequest.rootObjectKey,
          objectTreePagedRequest.pageSize
        )

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : objectTreeRequestUrl
            data    : objectTreePagedRequest.getRequestData()
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == com.kryptnostic.v2.storage.models.ObjectTreeLoadResponse
          objectId = objectTreePagedRequest.rootObjectKey.objectId
          objectMetadataTree = axiosResponse.data.objectMetadataTrees[objectId]
          isLastPage = _.size(objectMetadataTree.children) < objectTreePagedRequest.pageSize
          objectTreePagedResponse = new ObjectTreePagedResponse({
            objectMetadataTree
            isLastPage
          })
          return objectTreePagedResponse
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
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == com.kryptnostic.v2.storage.models.VersionedObjectKey
          return axiosResponse.data
        else
          return null

    createIndexSegments: (parentObjectKey, indexSegmentRequests) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : bulkIndexSegmentsUrl(parentObjectKey.objectId, parentObjectKey.objectVersion)
            data    : JSON.stringify(indexSegmentRequests)
            headers : DEFAULT_HEADERS
          })
        )
      )

    getObjectAsBlockCiphertext: (versionedObjectKey) ->
      Requests.getBlockCiphertextFromUrl(
        objectVersionCdnUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
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

    deleteObject: (objectId) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'DELETE'
            url     : objectIdUrl(objectId)
            headers : DEFAULT_HEADERS
          })
        )
      )

    updateType: (objectId, type) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method: 'POST',
            url: objectIdUrl(objectId) + '/type'
            headers: DEFAULT_HEADERS
            data: type
          })
        )
      )

  return ObjectApi
