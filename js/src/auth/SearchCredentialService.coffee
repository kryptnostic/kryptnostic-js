define 'kryptnostic.search-credential-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.authentication-stage'
  'kryptnostic.search-key-generator'
  'kryptnostic.key-storage-api'
  'kryptnostic.crypto-service-loader'
], (require) ->

  _                   = require 'lodash'
  Promise             = require 'bluebird'
  Logger              = require 'kryptnostic.logger'
  AuthenticationStage = require 'kryptnostic.authentication-stage'
  KeyStorageApi       = require 'kryptnostic.key-storage-api'
  SearchKeyGenerator  = require 'kryptnostic.search-key-generator'
  CryptoServiceLoader = require 'kryptnostic.crypto-service-loader'

  logger = Logger.get('SearchCredentialService')

  #
  # enumeration of credential types which the SearchCredentialService produces.
  #
  CredentialType = {
    FHE_PRIVATE_KEY : {
      getKey    : (clientKeys) -> clientKeys.fhePrivateKey
      getter    : -> KeyStorageApi.getFHEPrivateKey
      setter    : -> KeyStorageApi.setFHEPrivateKey
      stage     : AuthenticationStage.FHE_KEYGEN
      encrypt   : true
      decrypt   : true
      id        : 'KryptnosticEngine.PrivateKey'
    }
    SEARCH_PRIVATE_KEY : {
      getKey    : (clientKeys) -> clientKeys.searchPrivateKey
      getter    : -> KeyStorageApi.getFHESearchPrivateKey
      setter    : -> KeyStorageApi.setFHESearchPrivateKey
      stage     : AuthenticationStage.SEARCH_KEYGEN
      encrypt   : true
      decrypt   : true
      id        : 'KryptnosticEngine.SearchPrivateKey'
    }
    # the client FHE hash function never needs to be downloaded from the server, so we don't need a getter
    CLIENT_HASH_FUNCTION : {
      getKey    : (clientKeys) -> clientKeys.clientHashFunction
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

    #
    # @return Object
    #   {
    #    FHE_PRIVATE_KEY      : Uint8Array
    #    SEARCH_PRIVATE_KEY   : Uint8Array
    #    CLIENT_HASH_FUNCTION : Uint8Array
    #   }
    getAllCredentials: ->
      Promise.resolve()
      .then =>
        @ensureCredentialsInitialized()
      .then =>
        @getStoredCredentials()

    #
    # @return Object
    #   {
    #    FHE_PRIVATE_KEY      : Uint8Array
    #    SEARCH_PRIVATE_KEY   : Uint8Array
    #    CLIENT_HASH_FUNCTION : Uint8Array
    #   }
    getStoredCredentials: ->
      Promise.resolve()
      .then =>

        # create a map of CredentialType -> Promise<Credential>
        credentialPromises = _.mapValues(CredentialType, (credentialType) =>
          if credentialType.getter?
            loadCredential = credentialType.getter()
            return loadCredential()
          else
            return Promise.resolve()
        )

        # Promise.props() returns a Promise that is fulfilled when all the properties of the object are fulfilled,
        # so 'credentialPromises' will fulfill when all credential requests are fulfilled
        Promise.props(credentialPromises)
        .then (credentials) =>

          # we don't need to make requests for object crypto services if the credentials are falsey
          falseyFilteredCredentials = _.compact(_.values(credentials))
          if _.isEmpty(falseyFilteredCredentials)
            return credentials

          # create a map of CredentialType -> Promise<AesCryptoService>
          cryptoServicePromises = _.mapValues(CredentialType, (credentialType) =>
            # we expect getObjectCryptoService() to eventually return an instance of AesCryptoService
            return @cryptoServiceLoader.getObjectCryptoServiceV2(
              credentialType.id,
              { expectMiss : true }
            )
          )

          # Promise.props() returns a Promise that is fulfilled when all the properties of the object are fulfilled,
          # so 'cryptoServicePromises' will fulfill when all crypto service requests are fulfilled
          Promise.props(cryptoServicePromises)
          .then (aesCryptoServices) ->

            return _.mapValues(credentials, (value, key) ->

              # 'type' is they key into the CredentialType enum:
              #   - FHE_PRIVATE_KEY
              #   - SEARCH_PRIVATE_KEY

              type           = key
              credential     = value
              credentialType = CredentialType[type]

              if credential? and credentialType.decrypt is true
                aesCryptoService = aesCryptoServices[type]
                return aesCryptoService.decryptToUint8Array(credential)
              else
                return credential
            ) # end .mapValues()

    hasInitialized: ->
      Promise.resolve()
      .then =>
        @getStoredCredentials()
      .then (credentials) ->
        credentials    = _.compact(_.values(credentials))
        expectedLength = 2

        if _.isEmpty(credentials)
          return false
        else if credentials.length is expectedLength
          return true
        else
          return false

    initializeCredentials: (notifier) ->
      { clientKeys } = {}

      Promise.resolve()
      .then =>
        logger.info('generating search credentials')
        clientKeys = @searchKeyGenerator.generateClientKeys()
      .then =>
        @initializeCredential(CredentialType.FHE_PRIVATE_KEY, clientKeys, notifier)
      .then =>
        @initializeCredential(CredentialType.SEARCH_PRIVATE_KEY, clientKeys, notifier)
      .then =>
        @initializeCredential(CredentialType.CLIENT_HASH_FUNCTION, clientKeys, notifier)

    initializeCredential: (credentialType, clientKeys, notifier) ->
      { key, storeableKey } = {}

      Promise.resolve()
      .then ->
        logger.info('initializeCredential', credentialType.stage)
        Promise.resolve(notifier(credentialType.stage))
      .then =>
        # we expect getObjectCryptoService() to return an instance of AesCryptoService
        @cryptoServiceLoader.getObjectCryptoServiceV2(
          credentialType.id,
          { expectMiss: true }
        )
      .then (aesCryptoService) =>
        key = credentialType.getKey(clientKeys)
        storeableKey = key

        if credentialType.encrypt is true
          storeableKey = aesCryptoService.encryptUint8Array(key)

        storeCredential = credentialType.setter()
        storeCredential(storeableKey)

      .then ->
        return key

  return SearchCredentialService
