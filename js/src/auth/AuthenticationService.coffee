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
  'kryptnostic.kryptnostic-workers-api'
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
  KryptnosticWorkersApi     = require 'kryptnostic.kryptnostic-workers-api'

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
        credentialService.deriveCredential({ principal, password }, notifier)
      .then (_credential) ->
        credential = _credential
        credentialProvider.store({ principal, credential })
        credentialService.deriveKeyPair({ password }, notifier)
      .then (_keypair) ->
        keypair = _keypair
        credentialService.ensureValidRSAPublickKey(principal, keypair)
      .then ->
        credentialProvider.store({ principal, credential, keypair })
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
        Promise.resolve(
          KryptnosticWorkersApi.queryWebWorker(KryptnosticWorkersApi.FHE_KEYS_GEN_WORKER)
        )
        .catch (e) -> return null
      .then (fheKeys) ->
        KryptnosticWorkersApi.terminateWebWorker(KryptnosticWorkersApi.FHE_KEYS_GEN_WORKER)
        if not _.isEmpty(fheKeys)
          searchCredentialService.initializeKeys(fheKeys)
          return fheKeys
        else
          return searchCredentialService.getKeys()
      .then (keys) ->
        fhePrivateKey = keys.FHE_PRIVATE_KEY
        fheSearchPrivateKey = keys.FHE_SEARCH_PRIVATE_KEY
        KryptnosticEngineProvider.init({ fhePrivateKey, fheSearchPrivateKey })

        logger.info('KryptnosticEngine initialized')

        KryptnosticWorkersApi.startWebWorker(
          KryptnosticWorkersApi.OBJ_INDEXING_WORKER
        )
        return

    @destroy: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.destroy()

  return AuthenticationService
