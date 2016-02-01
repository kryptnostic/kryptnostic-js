define 'kryptnostic.search-client', [
  'require'
  'bluebird'
  'kryptnostic.binary-utils'
  'kryptnostic.logger'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.hash-function'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.object-api'
  'kryptnostic.search-api'
], (require) ->

  # libraries
  Promise = require 'bluebird'

  # APIs
  ObjectApi = require 'kryptnostic.object-api'
  SearchApi = require 'kryptnostic.search-api'


  # kryptnostic
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'

  # utils
  BinaryUtils  = require 'kryptnostic.binary-utils'
  HashFunction = require 'kryptnostic.hash-function'
  Logger       = require 'kryptnostic.logger'

  logger = Logger.get('SearchClient')

  #
  # Performs encrypted searches on the user's behalf.
  # Search takes in a plaintext token and returns a set of results.
  #
  class SearchClient

    constructor: ->
      @cryptoServiceLoader = new CryptoServiceLoader()
      @objectApi           = new ObjectApi()
      @searchApi           = new SearchApi()

    search: (searchToken) ->
      Promise.resolve()
      .then =>

        # token -> 128-bit hash -> Uint8Array
        tokenHash = HashFunction.SHA_256_TO_128(searchToken)
        tokenAsUint8 = BinaryUtils.stringToUint8(tokenHash)

        engine = KryptnosticEngineProvider.getEngine()
        encryptedSearchTokenAsUint8 = engine.calculateEncryptedSearchToken(tokenAsUint8)

        encryptedSearchTokenAsBase64 = BinaryUtils.uint8ToBase64(encryptedSearchTokenAsUint8)
        searchRequest = [encryptedSearchTokenAsBase64]
        @searchApi.search(searchRequest)

      .then (searchResults) =>
        #
        # searchResults is a Map of object UUIDs to a set of inverted index segment UUIDs
        #
        if not _.isEmpty(searchResults)
          #
          # since Promise.all() doesn't support a map, only an array, we're forced to lose the key-value pair
          # association in searchResults. as such, we'll keep track of the key, the objectId, by storing it in an
          # array as we iterate over the searchResults map. we're guaranteed that when the Promise resolves, the
          # data will be in the same order as given to Promise.all(), which means that we can just look up the key
          # in our array using the iteration index
          #
          objectIdSet = []

          invertedIndexSegmentPromises = _.map(searchResults, (invertedIndexSegmentIds, objectId) =>

            objectIdSet.push(objectId)
            invertedIndexSegmentsPromise = @objectApi.getObjects(invertedIndexSegmentIds)
            objectCryptoServicePromise = @cryptoServiceLoader.getObjectCryptoServiceV2(
              {
                objectId: objectId,
                objectVersion: 0 # !!! HACK !!! we're hardcoding version 0 for now
              },
              {
                expectMiss: false
              }
            )

            Promise.props({
              invertedIndexSegments : invertedIndexSegmentsPromise,
              objectCryptoService : objectCryptoServicePromise
            })
            .then ({ invertedIndexSegments, objectCryptoService }) ->
              #
              # invertedIndexSegments is a set of encrypted inverted index segments that we must decrypt using the
              # object crypto service for objectId
              #
              return _.map(invertedIndexSegments, (invertedIndexSegmentBlockCipherText) ->
                #
                # ToDo - we shouldn't have to do JSON.parse() here
                #
                invertedIndexSegmentJSON = objectCryptoService.decrypt(invertedIndexSegmentBlockCipherText)
                invertedIndexSegment = JSON.parse(invertedIndexSegmentJSON)
                return invertedIndexSegment
              )
            .catch (e) ->
              return []
          )

          Promise.all(invertedIndexSegmentPromises)
          .then (invertedIndexSegments) ->
            #
            # invertedIndexSegments is a 2D array, where each element is an array of inverted index segments
            #
            objectIdsToSegmentsMap = {}
            _.forEach(invertedIndexSegments, (invertedIndexSegmentsPerObject, iterationIndex) ->
              if not _.isEmpty(invertedIndexSegmentsPerObject)
                objectId = objectIdSet[iterationIndex]
                objectIdsToSegmentsMap[objectId] = invertedIndexSegmentsPerObject
            )
            #
            # we'll return a Map of key-value pairs, where the key is an object UUIDs and the value is a set of
            # decrypted inverted index segments
            #
            return objectIdsToSegmentsMap
          .catch (e) ->
            return {}
        else
          return {}
      .catch (e) ->
        return {}

  return SearchClient
