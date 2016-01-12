define 'kryptnostic.registration-client', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.registration-api'
  'kryptnostic.credential-service'
  'kryptnostic.user-registration-request'
], (require) ->

  Logger                  = require 'kryptnostic.logger'
  RegistrationApi         = require 'kryptnostic.registration-api'
  CredentialService       = require 'kryptnostic.credential-service'
  UserRegistrationRequest = require 'kryptnostic.user-registration-request'

  log = Logger.get('RegistrationClient')

  #
  # Allows user to register for a new account.
  #
  class RegistrationClient

    constructor: ->
      @registrationApi   = new RegistrationApi()
      @credentialService = new CredentialService()

    register: ({ email, name, password }) ->

      Promise.resolve(
        CredentialService.generateCredentialPair({ password })
      )
      .then (credentialPair) =>
        password = null
        { credential, encryptedSalt } = credentialPair
        userRegistrationRequest = new UserRegistrationRequest {
          email    : email
          name     : name
          password : credential
        }
        Promise.resolve(
          @registrationApi.register(userRegistrationRequest)
        )
        .then (uuid) =>
          log.info('registered new user account', { uuid })
          @credentialService.initializeSalt({ uuid, encryptedSalt, credential })
        .then ->
          log.info('initialized user salt')
          log.info('user registration complete')

  return RegistrationClient
