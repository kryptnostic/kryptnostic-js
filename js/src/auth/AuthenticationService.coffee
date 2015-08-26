define 'kryptnostic.authentication-service', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
  'kryptnostic.credential-provider-loader'
  'kryptnostic.credential-service'
  'kryptnostic.search-credential-service'
  'kryptnostic.authentication-stage'
  'kryptnostic.user-directory-api'
], (require) ->

  Promise                  = require 'bluebird'
  Logger                   = require 'kryptnostic.logger'
  Config                   = require 'kryptnostic.configuration'
  CredentialProviderLoader = require 'kryptnostic.credential-provider-loader'
  CredentialService        = require 'kryptnostic.credential-service'
  SearchCredentialService  = require 'kryptnostic.search-credential-service'
  AuthenticationStage      = require 'kryptnostic.authentication-stage'
  UserDirectoryApi         = require 'kryptnostic.user-directory-api'

  log = Logger.get('AuthenticationService')

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
      searchCredentialService = new SearchCredentialService()

      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))

      Promise.resolve()
      .then ->
        userDirectoryApi.resolve({ email })
      .then (uuid) ->
        if _.isEmpty(uuid)
          throw new Error LOGIN_FAILURE_MESSAGE
        principal = uuid
        log.info('authenticating', email)
        credentialService.deriveCredential({ principal, password }, notifier)
      .then (_credential) ->
        credential = _credential
        log.info('derived credential')
        credentialProvider.store { principal, credential }
        credentialService.deriveKeypair({ password }, notifier)
      .then (_keypair) ->
        keypair = _keypair
        credentialProvider.store { principal, credential, keypair }
      .then ->
        searchCredentialService.getFhePrivateKey(notifier)
      .then ->
        searchCredentialService.getSearchPrivateKey(notifier)
      .then ->
        searchCredentialService.getClientHashFunction(notifier)
      .then ->
        Promise.resolve(notifier(AuthenticationStage.COMPLETED))
      .then ->
        log.info('authentication complete')

    @destroy: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.destroy()

  return AuthenticationService
