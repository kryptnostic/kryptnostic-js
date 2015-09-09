define 'kryptnostic.search-client', [
  'require'
  'kryptnostic.binary-utils'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.kryptnostic-engine' #MOCK#
  'kryptnostic.search-api'
  'kryptnostic.search-credential-service' #added to load the keys stored
  'kryptnostic.kryptnostic-engine-provider'
], (require) ->

  BinaryUtils               = require 'kryptnostic.binary-utils'
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  KryptnosticObject         = require 'kryptnostic.kryptnostic-object'
  KryptnosticEngine         = require 'kryptnostic.kryptnostic-engine' #MOCK#
  SearchApi                 = require 'kryptnostic.search-api'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'

  #
  # Performs encrypted searches on the user's behalf.
  # Search takes in a plaintext token and returns a set of results.
  #
  # Author: rbuckheit
  #
  class SearchClient

    constructor: ->
      #@engine              = KryptnosticEngineProvider.getEngine()#new KryptnosticEngine() #MOCK#
      @cryptoServiceLoader = new CryptoServiceLoader()
      @searchApi           = new SearchApi()

    search: (token) ->
      Promise.resolve()
      .then =>
        token = BinaryUtils.stringToUint8(token)
        engine = KryptnosticEngineProvider.getEngine()
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
