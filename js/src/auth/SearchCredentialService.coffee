define 'kryptnostic.search-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.authentication-stage'
  'kryptnostic.search-key-generator'
  'kryptnostic.key-storage-api'
  'kryptnostic.kryptnostic-engine'
  'kryptnostic.crypto-service-loader'
], (require) ->

  _                   = require 'lodash'
  Promise             = require 'bluebird'
  Logger              = require 'kryptnostic.logger'
  AuthenticationStage = require 'kryptnostic.authentication-stage'
  KeyStorageApi       = require 'kryptnostic.key-storage-api'
  KryptnosticEngine   = require 'kryptnostic.kryptnostic-engine'
  SearchKeyGenerator  = require 'kryptnostic.search-key-generator'
  CryptoServiceLoader = require 'kryptnostic.crypto-service-loader'

  logger = Logger.get('SearchCredentialService')

  #
  # enumeration of credential types which the SearchCredentialService produces.
  #
  FHE_PRIVATE_KEY        = 'FHE_PRIVATE_KEY'
  FHE_SEARCH_PRIVATE_KEY = 'FHE_SEARCH_PRIVATE_KEY'

  CredentialType = {
    FHE_PRIVATE_KEY : {
      getKey    : (clientKeys) -> clientKeys.FHE_PRIVATE_KEY
      getter    : -> KeyStorageApi.getFHEPrivateKey
      setter    : -> KeyStorageApi.setFHEPrivateKey
      stage     : AuthenticationStage.FHE_KEYGEN
      encrypt   : true
      decrypt   : true
      id        : 'KryptnosticEngine.PrivateKey'
    }
    FHE_SEARCH_PRIVATE_KEY : {
      getKey    : (clientKeys) -> clientKeys.FHE_SEARCH_PRIVATE_KEY
      getter    : -> KeyStorageApi.getFHESearchPrivateKey
      setter    : -> KeyStorageApi.setFHESearchPrivateKey
      stage     : AuthenticationStage.SEARCH_KEYGEN
      encrypt   : true
      decrypt   : true
      id        : 'KryptnosticEngine.SearchPrivateKey'
    }
    # the client FHE hash function never needs to be downloaded from the server, so we don't need a getter
    FHE_HASH_FUNCTION : {
      getKey    : (clientKeys) -> clientKeys.FHE_HASH_FUNCTION
      setter    : -> KeyStorageApi.setFHEHashFunction
      stage     : AuthenticationStage.CLIENT_HASH_GEN
      encrypt   : false
      decrypt   : false
      id        : 'KryptnosticEngine.ClientHashFunction'
    }
  }

  #
  # loads or generates credentials produced by the SearchKeyGenerator, including:
  #   - fhe private key
  #   - search private key
  #   - client hash function
  #
  class SearchCredentialService

    constructor: ->
      @searchKeyGenerator  = new SearchKeyGenerator()
      @cryptoServiceLoader = new CryptoServiceLoader()

    #
    # @return Object
    #   {
    #    FHE_PRIVATE_KEY        : Uint8Array
    #    FHE_SEARCH_PRIVATE_KEY : Uint8Array
    #   }
    getKeys: ->
      Promise.resolve(
        @loadKeys()
      )
      .then (keys) =>
        if _.isEmpty(keys)
          return @initializeKeys()
        else
          return keys

    #
    # @return Object
    #   {
    #    FHE_PRIVATE_KEY        : Uint8Array
    #    FHE_SEARCH_PRIVATE_KEY : Uint8Array
    #   }
    loadKeys: ->
      Promise.props({
        masterAesCryptoService             : @cryptoServiceLoader.getMasterAesCryptoService()
        fhePrivateKeyBlockCiphertext       : KeyStorageApi.getFHEPrivateKey()
        fheSearchPrivateKeyBlockCiphertext : KeyStorageApi.getFHESearchPrivateKey()
      })
      .then ({ masterAesCryptoService, fhePrivateKeyBlockCiphertext, fheSearchPrivateKeyBlockCiphertext }) ->

        keys = {}

        if fhePrivateKeyBlockCiphertext and fheSearchPrivateKeyBlockCiphertext

          fhePrivateKey = masterAesCryptoService.decryptToUint8Array(fhePrivateKeyBlockCiphertext)
          # ToDo: validate fhePrivateKey
          keys[FHE_PRIVATE_KEY] = fhePrivateKey

          fheSearchPrivateKey = masterAesCryptoService.decryptToUint8Array(fheSearchPrivateKeyBlockCiphertext)
          # ToDo: validate fheSearchPrivateKey
          keys[FHE_SEARCH_PRIVATE_KEY] = fheSearchPrivateKey

        return keys

    initializeKeys: (fheKeys = {}) ->
      { clientKeys } = {}
      Promise.resolve()
      .then =>
        if not _.isEmpty(fheKeys) and
            KryptnosticEngine.isValidFHEPrivateKey(fheKeys.FHE_PRIVATE_KEY) and
            KryptnosticEngine.isValidFHESearchPrivateKey(fheKeys.FHE_SEARCH_PRIVATE_KEY) and
            KryptnosticEngine.isValidFHEHashFunction(fheKeys.FHE_HASH_FUNCTION)
          clientKeys = fheKeys
        else
          clientKeys = @searchKeyGenerator.generateClientKeys()
      .then =>
        @initializeKey(CredentialType.FHE_PRIVATE_KEY, clientKeys)
      .then =>
        @initializeKey(CredentialType.FHE_SEARCH_PRIVATE_KEY, clientKeys)
      .then =>
        @initializeKey(CredentialType.FHE_HASH_FUNCTION, clientKeys)
      .then ->
        return clientKeys

    initializeKey: (credentialType, clientKeys) ->
      Promise.resolve(
        @cryptoServiceLoader.getMasterAesCryptoService()
      )
      .then (masterAesCryptoService) ->
        key = credentialType.getKey(clientKeys)
        if credentialType.encrypt is true
          key = masterAesCryptoService.encryptUint8Array(key)
        storeCredential = credentialType.setter()
        storeCredential(key)

  return SearchCredentialService
