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
  CredentialStore          = require 'soteria.credential-store'
  CredentialProviderLoader = require 'soteria.credential-provider-loader'
  CredentialService        = require 'soteria.credential-service'
  UserUtils                = require 'soteria.user-utils'
  log = Logger.get('AuthenticationService')

  #
  # Allows user to authenticate and derives their credential.
  # Author: rbuckheit
  #
  class AuthenticationService

    @authenticate : ({username, password, realm}) ->
      providerUri       = Config.get('credentialProvider')
      credentialService = new CredentialService()

      log.info('authenticating', {username, realm})

      promises = {
        providerClass : CredentialProviderLoader.load(providerUri)
        credential    : credentialService.deriveCredential({username, password, realm})
      }

      Promise.props(promises)
      .then ({providerClass, credential}) ->
        log.info('derived credential', credential)
        credentialProvider = new providerClass()
        CredentialStore.store(credentialProvider)

        principal = UserUtils.componentsToPrincipal({realm, username})
        credentialProvider.store { principal, credential }

        return credentialService.deriveKeypair({password})
        .then (keypair) ->
          credentialProvider.store {principal, credential, keypair}
          log.info('authentication complete')

    @destroy: ->
      CredentialStore.destroy()

  return AuthenticationService
