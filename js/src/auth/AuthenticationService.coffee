define 'soteria.authentication-service', [
  'require'
  'bluebird'
  'soteria.logger'
  'soteria.configuration'
  'soteria.credential-provider-loader'
  'soteria.credential-service'
  'soteria.user-utils'
], (require) ->

  Promise                  = require 'bluebird'
  Logger                   = require 'soteria.logger'
  Config                   = require 'soteria.configuration'
  CredentialProviderLoader = require 'soteria.credential-provider-loader'
  CredentialService        = require 'soteria.credential-service'
  UserUtils                = require 'soteria.user-utils'

  log = Logger.get('AuthenticationService')

  #
  # Allows user to authenticate and derives their credential.
  # Author: rbuckheit
  #
  class AuthenticationService

    @authenticate: ({username, password, realm}) ->
      {principal, credential, keypair} = {}

      credentialService  = new CredentialService()
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      principal          = UserUtils.componentsToPrincipal({realm, username})

      Promise.resolve()
      .then ->
        log.info('authenticating', { username, realm })
        credentialService.deriveCredential { username, password, realm }
      .then (_credential) ->
        credential = _credential
        log.info('derived credential', credential)
        credentialProvider.store { principal, credential }
        credentialService.deriveKeypair({ password })
      .then (_keypair) ->
        keypair = _keypair
        credentialProvider.store { principal, credential, keypair }
        log.info('authentication complete')

    @destroy: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.destroy()

  return AuthenticationService
