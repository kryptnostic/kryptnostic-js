define 'kryptnostic.registration-client', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.registration-api'
  'kryptnostic.credential-service'
  'kryptnostic.user-registration-request'
  'kryptnostic.kryptnostic-workers-api'
], (require) ->

  Logger                  = require 'kryptnostic.logger'
  RegistrationApi         = require 'kryptnostic.registration-api'
  CredentialService       = require 'kryptnostic.credential-service'
  UserRegistrationRequest = require 'kryptnostic.user-registration-request'
  KryptnosticWorkersApi   = require 'kryptnostic.kryptnostic-workers-api'

  log = Logger.get('RegistrationClient')

  class RegistrationClient

    constructor: ->

      @registrationApi   = new RegistrationApi()
      @credentialService = new CredentialService()

      KryptnosticWorkersApi.startWebWorker(
        KryptnosticWorkersApi.FHE_KEYS_GEN_WORKER
      )

      KryptnosticWorkersApi.startWebWorker(
        KryptnosticWorkersApi.RSA_KEYS_GEN_WORKER
      )

    register: ({ email, name, password }) ->
      { credential, encryptedSalt } = CredentialService.generateCredentialPair({ password })
      password = null

      userRegistrationRequest = new UserRegistrationRequest {
        email    : email
        name     : name
        password : credential
      }

      Promise.resolve()
      .then =>
        @registrationApi.register(userRegistrationRequest)
      .then (uuid) =>
        log.info('registered new user account', { uuid })
        @credentialService.initializeSalt({ uuid, encryptedSalt, credential })
      .then ->
        log.info('initialized user salt')
        log.info('user registration complete')

  return RegistrationClient
