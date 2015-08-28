define 'kryptnostic.search-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.authentication-stage'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.crypto-key-storage-api'
  'kryptnostic.credential-loader'
  'kryptnostic.search-key-serializer'
], (require) ->

  _                     = require 'lodash'
  Promise               = require 'bluebird'
  Logger                = require 'kryptnostic.logger'
  AuthenticationStage   = require 'kryptnostic.authentication-stage'
  CredentialLoader      = require 'kryptnostic.credential-loader'
  RsaCryptoService      = require 'kryptnostic.rsa-crypto-service'
  CryptoKeyStorageApi   = require 'kryptnostic.crypto-key-storage-api'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  SearchKeySerializer   = require 'kryptnostic.search-key-serializer'

  log = Logger.get('SearchCredentialService')

  #
  # Enumeration of credential types which the SearchCredentialService produces.
  # Author: rbuckheit
  #
  CredentialType = {
    FHE_PRIVATE_KEY : {
      generator : (engine) -> engine.getFhePrivateKey
      getter    : (api) -> api.getFhePrivateKey
      setter    : (api) -> api.setFhePrivateKey
      stage     : AuthenticationStage.FHE_KEYGEN
    }
    SEARCH_PRIVATE_KEY : {
      generator : (engine) -> engine.getSearchPrivateKey
      getter    : (api) -> api.getSearchPrivateKey
      setter    : (api) -> api.setSearchPrivateKey
      stage     : AuthenticationStage.SEARCH_KEYGEN
    }
    CLIENT_HASH_FUNCTION : {
      generator : (engine) -> engine.getClientHashFunction
      getter    : (api) -> api.getClientHashFunction
      setter    : (api) -> api.setClientHashFunction
      stage     : AuthenticationStage.CLIENT_HASH_GEN
    }
  }


  #
  # Loads or generates credentials produced by the KryptnosticEngine.
  # These credentials include:
  #
  # 1) search private key
  # 2) fhe private key
  # 3) client hash function
  #
  # This class is designed to be used one-time during authentication.
  #
  # Author: rbuckheit
  #
  class SearchCredentialService

    constructor: ->
      @credentialLoader    = new CredentialLoader()
      @cryptoKeyStorageApi = new CryptoKeyStorageApi()
      @engine              = new MockKryptnosticEngine()
      @searchKeySerializer = new SearchKeySerializer()

    getFhePrivateKey: ( notifier = -> ) ->
      return @getOrInitialize(CredentialType.FHE_PRIVATE_KEY, notifier)

    getSearchPrivateKey: ( notifier = -> ) ->
      return @getOrInitialize(CredentialType.SEARCH_PRIVATE_KEY, notifier)

    getClientHashFunction: ( notifier = -> ) ->
      return @getOrInitialize(CredentialType.CLIENT_HASH_FUNCTION, notifier)

    # private
    # =======

    getRsaCryptoService : ->
      { keypair } = @credentialLoader.getCredentials()
      return new RsaCryptoService(keypair)

    getOrInitialize: (credentialType, notifier) ->
      log.warn('getOrInitialize')

      Promise.resolve()
      .then ->
        Promise.resolve(notifier(credentialType.stage))
      .then =>
        loadCredential = credentialType.getter(@cryptoKeyStorageApi)
        loadCredential()
      .then (uint8) =>
        if _.isEmpty(uint8)
          log.info('using initialized credential')
          return @initializeCredential(credentialType)
        else
          log.warn('credential not initialized, creating')
          return @searchKeySerializer.decrypt(uint8)

    initializeCredential: (credentialType) ->
      log.warn('initializeCredential')

      { uint8Key } = {}

      Promise.resolve()
      .then =>
        generateCredential = credentialType.generator(@engine)
        uint8Key           = generateCredential()
        encryptedKeyChunks = @searchKeySerializer.encrypt(uint8Key)
        storeCredential    = credentialType.setter(@cryptoKeyStorageApi)
        storeCredential(encryptedKeyChunks)
      .then ->
        return uint8Key

  return SearchCredentialService
