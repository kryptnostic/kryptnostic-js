define 'kryptnostic.search-client', [
  'require'
  'kryptnostic.binary-utils'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.search-api'
], (require) ->

  BinaryUtils           = require 'kryptnostic.binary-utils'
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  SearchApi             = require 'kryptnostic.search-api'

  #
  # Performs encrypted searches on the user's behalf.
  # Search takes in a plaintext token and returns a set of results.
  #
  # Author: rbuckheit
  #
  class SearchClient

    constructor: ->
      @engine              = new MockKryptnosticEngine()
      @cryptoServiceLoader = new CryptoServiceLoader()
      @searchApi           = new SearchApi()

    search: (token) ->
      Promise.resolve()
      .then =>
        token = BinaryUtils.stringToUint8(token)
        encryptedToken = @engine.getEncryptedSearchToken({ token })
        @searchApi.search(encryptedToken)
      .then (encryptedMetadata) ->
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
