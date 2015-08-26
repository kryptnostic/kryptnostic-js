define 'kryptnostic.search-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.authentication-stage'
  'kryptnostic.binary-utils'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.crypto-key-storage-api'
  'kryptnostic.credential-loader'
], (require) ->

  _                   = require 'lodash'
  Promise             = require 'bluebird'
  AuthenticationStage = require 'kryptnostic.authentication-stage'
  BinaryUtils         = require 'kryptnostic.binary-utils'
  CredentialLoader    = require 'kryptnostic.credential-loader'
  RsaCryptoService    = require 'kryptnostic.rsa-crypto-service'
  CryptoKeyStorageApi = require 'kryptnostic.crypto-key-storage-api'
  KryptnosticEngine   = require 'kryptnostic.kryptnostic-engine'


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
      @engine              = new KryptnosticEngine()

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
      Promise.resolve()
      .then ->
        Promise.resolve(notifier(credentialType.stage))
      .then =>
        loadCredential = credentialType.getter(@cryptoKeyStorageApi)
        loadCredential()
      .then (blockCiphertext) =>
        if _.isEmpty(blockCiphertext)
          return @initializeCredential(credentialType)
        else
          return @getRsaCryptoService().decrypt(blockCiphertext)

    initializeCredential: (credentialType) ->
      { stringKey } = {}

      Promise.resolve()
      .then =>
        generateCredential = credentialType.generator(@engine)
        uintKey            = generateCredential()
        stringKey          = BinaryUtils.uint8ToString(uintKey)
        blockCiphertext    = @getRsaCryptoService().encrypt(stringKey)

        storeCredential = credentialType.setter(@cryptoKeyStorageApi)
        storeCredential(blockCiphertext)
      .then ->
        return stringKey

  return SearchCredentialService
