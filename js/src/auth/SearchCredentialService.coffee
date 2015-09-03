define 'kryptnostic.search-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.authentication-stage'
  'kryptnostic.search-key-generator'
  'kryptnostic.mock.search-key-generator'
  'kryptnostic.crypto-key-storage-api'
  'kryptnostic.credential-loader'
  'kryptnostic.search-key-serializer'
], (require) ->

  _                      = require 'lodash'
  Promise                = require 'bluebird'
  Logger                 = require 'kryptnostic.logger'
  AuthenticationStage    = require 'kryptnostic.authentication-stage'
  CredentialLoader       = require 'kryptnostic.credential-loader'
  CryptoKeyStorageApi    = require 'kryptnostic.crypto-key-storage-api'
  SearchKeySerializer    = require 'kryptnostic.search-key-serializer'
  SearchKeyGenerator     = require 'kryptnostic.search-key-generator'

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
      encrypt   : true
    }
    SEARCH_PRIVATE_KEY : {
      generator : (clientKeys) -> clientKeys.searchPrivateKey
      getter    : (api) -> api.getSearchPrivateKey
      setter    : (api) -> api.setSearchPrivateKey
      stage     : AuthenticationStage.SEARCH_KEYGEN
      encrypt   : true
    }
    CLIENT_HASH_FUNCTION : {
      generator : (clientKeys) -> clientKeys.clientHashFunction
      getter    : (api) -> api.getClientHashFunction
      setter    : (api) -> api.setClientHashFunction
      stage     : AuthenticationStage.CLIENT_HASH_GEN
      encrypt   : false
    }
  }

  serializeKey = ({ credentialType, uint8Key, searchKeySerializer }) ->
    if _.isEmpty(uint8Key)
      return uint8Key
    else if credentialType.encrypt
      return searchKeySerializer.encrypt(uint8Key)
    else
      return uint8Key

  deserializeKey = ({ credentialType, uint8Key, searchKeySerializer }) ->
    if _.isEmpty(uint8Key)
      return uint8Key
    else if credentialType.encrypt
      return searchKeySerializer.decrypt(uint8Key)
    else
      return uint8Key

  #
  # Loads or generates credentials produced by the SearchKeyGenerator, including
  # search private key, fhe private key, and client hash function.
  #
  # Author: rbuckheit
  #
  class SearchCredentialService

    constructor: ->
      @credentialLoader    = new CredentialLoader()
      @cryptoKeyStorageApi = new CryptoKeyStorageApi()
      @searchKeyGenerator  = new SearchKeyGenerator()
      @searchKeySerializer = new SearchKeySerializer()

    # initializes keys if needed.
    ensureCredentialsInitialized: ( notifier = -> ) ->
      Promise.resolve()
      .then =>
        @hasInitialized()
      .then (initialized) =>
        if !initialized
          return @initializeCredentials(notifier)
        else
          return Promise.resolve()

    getAllCredentials: ->
      Promise.resolve()
      .then =>
        @ensureCredentialsInitialized()
      .then =>
        @getStoredCredentials()

    # private
    # =======

    getStoredCredentials: ->
      Promise.resolve()
      .then =>
        credentialPromises = _.mapValues(CredentialType, (credentialType) =>
          loadCredential = credentialType.getter(@cryptoKeyStorageApi)
          return loadCredential()
        )
        Promise.props(credentialPromises)
      .then (credentialsByType) =>
        return _.mapValues(credentialsByType, (credential, typeKey) =>
          credentialType = CredentialType[typeKey]
          uint8Key       = credential
          return deserializeKey({ credentialType, uint8Key, @searchKeySerializer })
        )

    hasInitialized: ->
      Promise.resolve()
      .then =>
        @getStoredCredentials()
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

    initializeCredentials: (notifier) ->
      { clientKeys } = {}

      Promise.resolve()
      .then =>
        log.info('generating search credentials')
        clientKeys = @searchKeyGenerator.generateClientKeys()
      .then =>
        @initializeCredential(CredentialType.FHE_PRIVATE_KEY, clientKeys, notifier)
      .then =>
        @initializeCredential(CredentialType.SEARCH_PRIVATE_KEY, clientKeys, notifier)
      .then =>
        @initializeCredential(CredentialType.CLIENT_HASH_FUNCTION, clientKeys, notifier)

    initializeCredential: (credentialType, clientKeys, notifier) ->
      { uint8Key, storeableKey } = {}

      Promise.resolve()
      .then ->
        log.info('initializeCredential', credentialType.stage)
        Promise.resolve(notifier(credentialType.stage))
      .then =>
        uint8Key        = credentialType.generator(clientKeys)
        storeableKey    = serializeKey({ credentialType, uint8Key, @searchKeySerializer })
        storeCredential = credentialType.setter(@cryptoKeyStorageApi)
        storeCredential(storeableKey)
      .then ->
        return uint8Key

  return SearchCredentialService
