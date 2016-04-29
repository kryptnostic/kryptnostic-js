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
  'kryptnostic.object-tree-paged-response'
], (require) ->

  axios                 = require 'axios'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'
  Requests              = require 'kryptnostic.requests'
  Logger                = require 'kryptnostic.logger'
  Config                = require 'kryptnostic.configuration'
  Promise               = require 'bluebird'
  ObjectMetadata        = require 'kryptnostic.object-metadata'
  ObjectMetadataTree    = require 'kryptnostic.object-metadata-tree'
  Validators            = require 'kryptnostic.validators'
  ObjectTreePagedResponse = require 'kryptnostic.object-tree-paged-response'

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
  indexSegmentUrl = -> objectUrl() + '/index-segment'
  latestObjectIdUrl = (objectId) -> objectUrl() + '/latest/id/' + objectId
  objectMetadataUrl = (objectId) -> objectUrl() + '/objectmetadata/id/' + objectId

  objectLevelsUrl = -> objectUrl() + '/levels'
  objectTreePagedUrl = ({ objectKey, pageSize }) ->
    objectLevelsUrl() + '/' + objectKey.objectId + '/' + pageSize
  objectTreeNextPageUrl = ({ objectKey, pageSize, latestObjectId, latestObjectVersion }) ->
    objectTreePagedUrl(objectKey, pageSize) + '/' + latestObjectId + '/' + latestObjectVersion

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
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.v2.storage.models.ObjectMetadata
          return new ObjectMetadata(axiosResponse.data)
        else
          return null

    getObjectsByTypeAndLoadLevel: (objectIds, typeLoadLevels, loadDepth, createdAfter, objectIdsToFilter) ->

      requestData = {
        objectIds         : objectIds
        loadLevels        : typeLoadLevels
        depth             : loadDepth
        createdAfter      : createdAfter
        objectIdsToFilter : objectIdsToFilter
      }

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : objectLevelsUrl()
            data    : requestData
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == Map<java.util.UUID, com.kryptnostic.v2.storage.models.ObjectMetadataEncryptedNode>
          # return new ObjectMetadataTree(axiosResponse.data)
          return axiosResponse.data
        else
          return null

    getObjectTreeByTypeAndLoadLevelPaged: (objectTreePagedRequest) ->

      if objectTreePagedRequest.latestObjectId and objectTreePagedRequest.latestObjectVersion
        objectTreeRequestUrl = objectTreeNextPageUrl(objectTreePagedRequest)
      else if objectTreePagedRequest.nextPageUrlPath
        objectTreeRequestUrl = objectUrl() + objectTreePagedRequest.nextPageUrlPath
      else
        objectTreeRequestUrl = objectTreePagedUrl(objectTreePagedRequest)

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
          objectId = objectTreePagedRequest.objectKey.objectId
          objectMetadataTree = axiosResponse.data.objectMetadataTrees[objectId]
          nextPageUrlPath = axiosResponse.data.scrollUp
          #
          # !!!HACK!!! the backend will incorrectly return a valid scrollUp when:
          #   1. there is only a single page, i.e., when the total number of children is less than the page size
          #   2. we've reached the last page
          #
          if not _.isEmpty(nextPageUrlPath) and (_.size(objectMetadataTree.children) < objectTreePagedRequest.pageSize)
            nextPageUrlPath = null
          objectTreePagedResponse = new ObjectTreePagedResponse({
            objectMetadataTree
            nextPageUrlPath
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
