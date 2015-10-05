define 'kryptnostic.search-client', [
  'require'
  'kryptnostic.binary-utils'
  'kryptnostic.logger'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.hash-function'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.search-api'
  'kryptnostic.search-request'
], (require) ->

  # kryptnostic
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'
  KryptnosticObject         = require 'kryptnostic.kryptnostic-object'
  SearchApi                 = require 'kryptnostic.search-api'
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
      @cryptoServiceLoader = CryptoServiceLoader.get()
      @searchApi           = new SearchApi()
      @hashFunction        = HashFunction.MURMUR3_128

    search: (searchTerm) ->
      Promise.resolve()
      .then =>

        # token -> 128 bit hex -> Uint8Array
        tokenHex  = @hashFunction(searchTerm)
        tokenUint = BinaryUtils.hexToUint(tokenHex)

        encryptedSearchToken = KryptnosticEngineProvider
          .getEngine()
          .calculateEncryptedSearchToken(tokenUint)
        encryptedSearchTokenAsBase64 = BinaryUtils.uint8ToBase64(encryptedSearchToken)
        searchRequest = new SearchRequest({
          query: [encryptedSearchTokenAsBase64]
        })
        @searchApi.search(searchRequest)
      .then (encryptedMetadata) =>
        Promise.all(_.map(encryptedMetadata, (encryptedMetadatum) =>
          return @decryptMetadatum(encryptedMetadatum)
        ))
      .then (decryptedMetadata) ->
        return decryptedMetadata

    decryptMetadatum: (encryptedMetadatum) ->
      Promise.resolve()
      .then =>
        id = encryptedMetadatum.key
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss: false })
      .then (cryptoService) ->
        body = encryptedMetadatum
        kryptnosticObject = KryptnosticObject.createFromEncrypted({ body })
        kryptnosticObject.setChunkingStrategy(JsonChunkingStrategy.URI)
        decrypted = kryptnosticObject.decrypt(cryptoService)
        return decrypted.body

  return SearchClient
