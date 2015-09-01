define 'kryptnostic.search-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.authentication-stage'
  'kryptnostic.search-key-generator'
  'kryptnostic.crypto-key-storage-api'
  'kryptnostic.credential-loader'
  'kryptnostic.search-key-serializer'
], (require) ->

  _                   = require 'lodash'
  Promise             = require 'bluebird'
  Logger              = require 'kryptnostic.logger'
  AuthenticationStage = require 'kryptnostic.authentication-stage'
  CredentialLoader    = require 'kryptnostic.credential-loader'
  CryptoKeyStorageApi = require 'kryptnostic.crypto-key-storage-api'
  SearchKeySerializer = require 'kryptnostic.search-key-serializer'
  SearchKeyGenerator  = require 'kryptnostic.search-key-generator'

  log = Logger.get('SearchCredentialService')

  #
  # Enumeration of credential types which the SearchCredentialService produces.
  # Author: rbuckheit
  #
  CredentialType = {
    FHE_PRIVATE_KEY : {
      generator : (clientKeys) -> clientKeys.fhePrivateKey
      getter    : (api) -> api.getFhePrivateKey
      setter    : (api) -> api.setFhePrivateKey
      stage     : AuthenticationStage.FHE_KEYGEN
    }
    SEARCH_PRIVATE_KEY : {
      generator : (clientKeys) -> clientKeys.searchPrivateKey
      getter    : (api) -> api.getSearchPrivateKey
      setter    : (api) -> api.setSearchPrivateKey
      stage     : AuthenticationStage.SEARCH_KEYGEN
    }
    CLIENT_HASH_FUNCTION : {
      generator : (clientKeys) -> clientKeys.clientHashFunction
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
      @searchKeyGenerator  = new SearchKeyGenerator()
      @searchKeySerializer = new SearchKeySerializer()

    getFhePrivateKey: ->
      return @getCredential('FHE_PRIVATE_KEY')

    getSearchPrivateKey: ->
      return @getCredential('SEARCH_PRIVATE_KEY')

    getClientHashFunction: ->
      return @getCredential('CLIENT_HASH_FUNCTION')

    # TODO fix notifier

    # private
    # =======

    getCredential: (key) ->
      Promise.resolve()
      .then =>
        @ensureCredentialsInitialized()
      .then =>
        @getAllCredentials()
      .then (allCredentials) ->
        log.info('allCredentials', allCredentials)
        return allCredentials[key]

    # initializes keys if needed.
    ensureCredentialsInitialized: ->
      Promise.resolve()
      .then =>
        @hasInitialized()
      .then (initialized) =>
        if !initialized
          return @initializeCredentials()
        else
          return Promise.resolve()

    getAllCredentials: ->
      Promise.resolve()
      .then =>
        credentialPromises = _.mapValues(CredentialType, (credentialType) =>
          loadCredential = credentialType.getter(@cryptoKeyStorageApi)
          return loadCredential()
        )
        Promise.props(credentialPromises)
      .then (credentialsByType) =>
        return _.mapValues(credentialsByType, (credential) =>
          if _.isEmpty(credential)
            return credential
          else
            return @searchKeySerializer.decrypt(credential)
        )

    hasInitialized: ->
      Promise.resolve()
      .then =>
        @getAllCredentials()
      .then (credentials) ->
        credentials    = _.compact(_.values(credentials))
        expectedLength = _.size(_.values(CredentialType))

        if _.isEmpty(credentials)
          return false
        else if credentials.length is expectedLength
          return true
        else
          log.error('user account is in a partially initialized state')
          log.error("expected #{expectedLength} credentials but got #{credentials.length}")
          throw new Error 'credentials are in a partially initialized state'

    initializeCredentials: ->
      Promise.resolve()
      .then =>
        clientKeys = @searchKeyGenerator.generateClientKeys()
        storePromises = _.mapValues(CredentialType, (credentialType) =>
          @initializeCredential(credentialType, clientKeys)
        )
        Promise.props(storePromises)

    initializeCredential: (credentialType, clientKeys) ->
      { uint8Key } = {}

      Promise.resolve()
      .then =>
        uint8Key           = credentialType.generator(clientKeys)
        encryptedKeyChunks = @searchKeySerializer.encrypt(uint8Key)
        storeCredential    = credentialType.setter(@cryptoKeyStorageApi)
        storeCredential(encryptedKeyChunks)
      .then ->
        return uint8Key

  return SearchCredentialService
