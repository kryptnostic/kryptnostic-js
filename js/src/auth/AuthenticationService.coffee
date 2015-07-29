define 'kryptnostic.authentication-service', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
  'kryptnostic.credential-provider-loader'
  'kryptnostic.credential-service'
  'kryptnostic.user-utils'
  'kryptnostic.authentication-stage'
], (require) ->

  Promise                  = require 'bluebird'
  Logger                   = require 'kryptnostic.logger'
  Config                   = require 'kryptnostic.configuration'
  CredentialProviderLoader = require 'kryptnostic.credential-provider-loader'
  CredentialService        = require 'kryptnostic.credential-service'
  UserUtils                = require 'kryptnostic.user-utils'
  AuthenticationStage      = require 'kryptnostic.authentication-stage'

  log = Logger.get('AuthenticationService')

  #
  # Allows user to authenticate and derives their credential.
  # Author: rbuckheit
  #
  class AuthenticationService

    @authenticate: ( { username, password, realm }, authCallback = -> ) ->
      { principal, credential, keypair } = {}

      credentialService  = new CredentialService()
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      principal          = UserUtils.componentsToPrincipal({ realm, username })

      Promise.resolve()
      .then ->
        log.info('authenticating', { username, realm })
        credentialService.deriveCredential({ username, password, realm }, authCallback)
      .then (_credential) ->
        credential = _credential
        log.info('derived credential')
        credentialProvider.store { principal, credential }
        credentialService.deriveKeypair({ password }, authCallback)
      .then (_keypair) ->
        keypair = _keypair
        credentialProvider.store { principal, credential, keypair }
        authCallback(AuthenticationStage.COMPLETED)
        log.info('authentication complete')

    @destroy: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.destroy()

  return AuthenticationService
