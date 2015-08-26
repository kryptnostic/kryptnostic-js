define 'kryptnostic.search-key-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.binary-utils'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.crypto-key-storage-api'
  'kryptnostic.credential-loader'
], (require) ->

  _                     = require 'lodash'
  Promise               = require 'bluebird'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  CredentialLoader      = require 'kryptnostic.credential-loader'
  RsaCryptoService      = require 'kryptnostic.rsa-crypto-service'
  CryptoKeyStorageApi   = require 'kryptnostic.crypto-key-storage-api'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'


  #
  # Enumeration of credential types which the SearchKeyCredentialService produces.
  # Author: rbuckheit
  #
  CredentialType = {
    FHE_PRIVATE_KEY : {
      generator : (engine) -> engine.getFhePrivateKey
      getter    : (api) -> api.getFhePrivateKey
      setter    : (api) -> api.setFhePrivateKey
    }
    SEARCH_PRIVATE_KEY : {
      generator : (engine) -> engine.getSearchPrivateKey
      getter    : (api) -> api.getSearchPrivateKey
      setter    : (api) -> api.setSearchPrivateKey
    }
    CLIENT_HASH_FUNCTION : {
      generator : (engine) -> engine.getClientHashFunction
      getter    : (api) -> api.getClientHashFunction
      setter    : (api) -> api.setClientHashFunction
    }
  }


  #
  # Loads or generates credentials produced by the KryptnosticEngine.
  # These include:
  #
  # 1) search private key
  # 2) fhe private key
  # 3) client hash function
  #
  # This class is designed to be used one-time during authentication.
  #
  # Author: rbuckheit
  #
  class SearchKeyCredentialService

    constructor: ->
      @credentialLoader    = new CredentialLoader()
      @cryptoKeyStorageApi = new CryptoKeyStorageApi()
      @engine              = new MockKryptnosticEngine()

    getFhePrivateKey: ->
      return @getOrInitialize(CredentialType.FHE_PRIVATE_KEY)

    getSearchPrivateKey: ->
      return @getOrInitialize(CredentialType.SEARCH_PRIVATE_KEY)

    getClientHashFunction: ->
      return @getOrInitialize(CredentialType.CLIENT_HASH_FUNCTION)

    # private
    # =======

    getRsaCryptoService : ->
      { keypair } = @credentialLoader.getCredentials()
      return new RsaCryptoService(keypair)

    getOrInitialize: (credentialType) ->
      Promise.resolve()
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

  return SearchKeyCredentialService
