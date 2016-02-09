define 'kryptnostic.authentication-service', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
  'kryptnostic.credential-provider-loader'
  'kryptnostic.credential-service'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.search-credential-service'
  'kryptnostic.authentication-stage'
  'kryptnostic.user-directory-api'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.crypto-service-migrator'
], (require) ->

  Promise                   = require 'bluebird'
  Logger                    = require 'kryptnostic.logger'
  Config                    = require 'kryptnostic.configuration'
  CredentialProviderLoader  = require 'kryptnostic.credential-provider-loader'
  CredentialService         = require 'kryptnostic.credential-service'
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  SearchCredentialService   = require 'kryptnostic.search-credential-service'
  AuthenticationStage       = require 'kryptnostic.authentication-stage'
  UserDirectoryApi          = require 'kryptnostic.user-directory-api'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'
  CryptoServiceMigrator     = require 'kryptnostic.crypto-service-migrator'

  logger = Logger.get('AuthenticationService')

  LOGIN_FAILURE_MESSAGE = 'invalid credentials'

  #
  # Allows user to authenticate and derives their credential.
  # Author: rbuckheit
  #
  class AuthenticationService

    # authenticates, and forces initialization of keys if needed.
    @authenticate: ( { email, password }, notifier = -> ) ->
      { principal, credential, keypair } = {}

      credentialService       = new CredentialService()
      userDirectoryApi        = new UserDirectoryApi()

      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))

      Promise.resolve()
      .then ->
        userDirectoryApi.resolve({ email })
      .then (uuid) ->
        if _.isEmpty(uuid)
          throw new Error LOGIN_FAILURE_MESSAGE
        principal = uuid
        logger.info('authenticating', email)
        credentialService.deriveCredential({ principal, password }, notifier)
      .then (_credential) ->
        credential = _credential
        logger.info('derived credential')
        credentialProvider.store { principal, credential }
        credentialService.deriveKeyPair({ password })
      .then (_keypair) ->
        keypair = _keypair
        credentialProvider.store { principal, credential, keypair }
      .then ->
        CryptoServiceLoader.initializeMasterAesCryptoService()
      .then ->
        AuthenticationService.initializeEngine()
      .then ->
        cryptoServiceMigrator = new CryptoServiceMigrator()
        cryptoServiceMigrator.migrateRSACryptoServices()
      .then ->
        Promise.resolve(notifier(AuthenticationStage.COMPLETED))
      .then ->
        logger.info('authentication complete')

    @initializeEngine: ->

      searchCredentialService = new SearchCredentialService()

      Promise.resolve()
      .then ->
        searchCredentialService.getKeys()
      .then (keys) ->
        fhePrivateKey = keys.FHE_PRIVATE_KEY
        fheSearchPrivateKey = keys.FHE_SEARCH_PRIVATE_KEY
        KryptnosticEngineProvider.init({ fhePrivateKey, fheSearchPrivateKey })
        logger.info('KryptnosticEngine initialized')

    @destroy: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.destroy()

  return AuthenticationService
