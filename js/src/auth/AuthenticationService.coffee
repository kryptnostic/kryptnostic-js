define 'soteria.authentication-service', [
  'require'
  'bluebird'
  'soteria.configuration'
  'soteria.credential-service'
  'soteria.credential-provider-loader'
], (require) ->

  Promise                  = require 'bluebird'
  Config                   = require 'soteria.configuration'
  Logger                   = require 'soteria.logger'
  CredentialService        = require 'soteria.credential-service'
  CredentialProviderLoader = require 'soteria.credential-provider-loader'

  log = Logger.get('AuthenticationService')

  #
  # Allows user to authenticate and derives their credential.
  # Author: rbuckheit
  #
  class AuthenticationService

    @authenticate : ({username, password, realm}) ->
      if @credentialProvider?
        throw new Error 'user has already authenticated'

      providerUri       = Config.get('credentialProvider')
      credentialService = new CredentialService()

      log.info('authenticating', {username, realm})

      promises = {
        providerClass : CredentialProviderLoader.load(providerUri)
        credential    : credentialService.deriveCredential({username, password, realm})
      }

      Promise.props(promises)
      .then ({providerClass, credential}) =>
        @credentialProvider = new providerClass()
        principal = "#{realm}|#{username}"
        log.info('derived credential', credential)
        @credentialProvider.store({principal, credential})
        log.info('authentication complete')

    @unauthenticate: ->
      log.info('unauthenticating')
      if @credentialProvider?
        @credentialProvider.destroy()

  return AuthenticationService
