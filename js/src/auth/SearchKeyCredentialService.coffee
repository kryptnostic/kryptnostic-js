define 'kryptnostic.search-key-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.binary-utils'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.password-crypto-service'
  'kryptnostic.crypto-key-storage-api'
], (require) ->

  _                     = require 'lodash'
  Promise               = require 'bluebird'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  PasswordCryptoService = require 'kryptnostic.password-crypto-service'
  CryptoKeyStorageApi   = require 'kryptnostic.crypto-key-storage-api'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'

  decryptKey = ({ blockCiphertext, password }) ->
    passwordCrypto = new PasswordCryptoService()
    return passwordCrypto.decrypt(blockCiphertext, password)

  encryptKey = ({ stringKey, password }) ->
    passwordCrypto = new PasswordCryptoService()
    return passwordCrypto.encrypt(stringKey, password)

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
      @cryptoKeyStorageApi = new CryptoKeyStorageApi()
      @engine              = new MockKryptnosticEngine()

    # get or initialize fhe search private key.
    getFheSearchKey: ({ password }) ->
      Promise.resolve()
      .then =>
        @cryptoKeyStorageApi.getFhePrivateKey()
      .then (blockCiphertext) =>
        if _.isEmpty(blockCiphertext)
          return @initializeFheSearchKey({ password })
        else
          return decryptKey({ blockCiphertext, password })

    # private
    # =======

    initializeFheSearchKey: ({ password }) ->
      { stringKey } = {}

      Promise.resolve()
      .then =>
        uintKey         = @engine.getFhePrivateKey()
        stringKey       = BinaryUtils.uint8ToString(uintKey)
        blockCiphertext = encryptKey({ stringKey, password })
        @cryptoKeyStorageApi.setFhePrivateKey(blockCiphertext)
      .then ->
        return stringKey

  return SearchKeyCredentialService
