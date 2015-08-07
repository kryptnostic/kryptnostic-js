define 'kryptnostic.authentication-service', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
  'kryptnostic.credential-provider-loader'
  'kryptnostic.credential-service'
  'kryptnostic.authentication-stage'
  'kryptnostic.user-directory-api'
], (require) ->

  Promise                  = require 'bluebird'
  Logger                   = require 'kryptnostic.logger'
  Config                   = require 'kryptnostic.configuration'
  CredentialProviderLoader = require 'kryptnostic.credential-provider-loader'
  CredentialService        = require 'kryptnostic.credential-service'
  AuthenticationStage      = require 'kryptnostic.authentication-stage'
  UserDirectoryApi         = require 'kryptnostic.user-directory-api'

  log = Logger.get('AuthenticationService')

  #
  # Allows user to authenticate and derives their credential.
  # Author: rbuckheit
  #
  class AuthenticationService

    @authenticate: ( { email, password }, notifier = -> ) ->
      { principal, credential, keypair } = {}

      credentialService  = new CredentialService()
      userDirectoryApi   = new UserDirectoryApi()
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))

      Promise.resolve()
      .then ->
        userDirectoryApi.resolve({ email })
      .then (uuid) ->
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
        notifier(AuthenticationStage.COMPLETED)
        log.info('authentication complete')

    @destroy: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.destroy()

  return AuthenticationService
