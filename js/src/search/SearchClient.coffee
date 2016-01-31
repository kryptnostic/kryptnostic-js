define 'kryptnostic.search-client', [
  'require'
  'bluebird'
  'kryptnostic.binary-utils'
  'kryptnostic.logger'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.hash-function'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.object-api'
  'kryptnostic.search-api'
  'kryptnostic.search-request'
], (require) ->

  # libraries
  Promise = require 'bluebird'

  # APIs
  ObjectApi = require 'kryptnostic.object-api'
  SearchApi = require 'kryptnostic.search-api'


  # kryptnostic
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  JsonChunkingStrategy      = require 'kryptnostic.chunking.strategy.json'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'
  KryptnosticObject         = require 'kryptnostic.kryptnostic-object'
  SearchRequest             = require 'kryptnostic.search-request'

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

        encryptedSearchTokenAsUint8 = KryptnosticEngineProvider
          .getEngine()
          .calculateEncryptedSearchToken(tokenAsUint8)

        encryptedSearchTokenAsBase64 = BinaryUtils.uint8ToBase64(encryptedSearchTokenAsUint8)
        searchRequest = [encryptedSearchTokenAsBase64]
        @searchApi.search(searchRequest)

      .then (searchResults) =>

        if not _.isEmpty(searchResults)

          objectIdSet = []
          indexSegmentIdsSet = []

          indexSegmentPromises = _.map(searchResults, (indexSegmentIds, objectId) =>

            objectIdSet.push(objectId)
            indexSegmentIdsSet.push(indexSegmentIds)

            # !!! HACK !!!
            objectKey = {
              objectId : objectId,
              objectVersion : 0
            }

            Promise.props({
              encryptedIndexSegments : @objectApi.getObjects(indexSegmentIds),
              objectCryptoService : @cryptoServiceLoader.getObjectCryptoServiceV2(objectKey, { expectMiss: false })
            })
            .then ({ encryptedIndexSegments, objectCryptoService }) =>
              return _.map(encryptedIndexSegments, (indexSegmentBlockCipherText) ->
                invertedIndexSegmentJSON = objectCryptoService.decrypt(indexSegmentBlockCipherText)
                invertedIndexSegment = JSON.parse(invertedIndexSegmentJSON)
                return invertedIndexSegment
              )
          )

          Promise.all(indexSegmentPromises)
          .then (processedSearchResults) ->
            response = {}
            _.forEach(processedSearchResults, (invertedIndexSegments, i) ->
              objectId = objectIdSet[i]
              response[objectId] = invertedIndexSegments
            )
            return response
        else
          return []

      # .catch (e) ->
      #   logger.error('search failure')
      #   logger.error(e)
      #   return null

    # processSearchResult: (searchResult) ->
    #
    #   # searchResult.metadata is a Collection of Encryptables
    #   encryptables = searchResult.metadata
    #
    #   # _.map() will produce an Array of Promises for each encryptable
    #   encryptablePromises = _.map(encryptables, (encryptable) =>
    #     Promise.resolve(
    #       @objectApi.getLatestVersionedObjectKey(encryptable.key)
    #     )
    #     .then (versionedObjectKey) =>
    #       @cryptoServiceLoader.getObjectCryptoServiceV2(
    #         versionedObjectKey,
    #         { expectMiss: false }
    #       )
    #     .then (objectCryptoService) =>
    #       @decryptEncryptable(encryptable, objectCryptoService)
    #     .catch (e) ->
    #       logger.error('failure while processing search results', e)
    #       return null
    #   )
    #
    #   # this promise will fulfill when all encryptable promises are fulfilled
    #   Promise.all(encryptablePromises)
    #   .then (decryptedEncryptables) ->
    #     return decryptedEncryptables
    #
    # decryptEncryptable: (encryptable, objectCryptoService) ->
    #   encryptedKryptnosticObject = KryptnosticObject.createFromEncrypted({
    #     body: encryptable
    #   })
    #   encryptedKryptnosticObject.setChunkingStrategy(JsonChunkingStrategy.URI)
    #   decryptedKryptnosticObject = encryptedKryptnosticObject.decrypt(objectCryptoService)
    #   # DOTO - this is a hack; need to figure out a better way to return the right data
    #   merged = _.merge(encryptedKryptnosticObject, decryptedKryptnosticObject)
    #   return merged

  return SearchClient
