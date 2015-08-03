define 'kryptnostic.registration-client', [
  'require'
  'kryptnostic.registration-api'
], (require) ->
  'use strict'

  RegistrationApi = require 'kryptnostic.registration-api'

  #
  # Allows user to register for a new account.
  #
  class RegistrationClient

    constructor : ->
      @registrationApi = new RegistrationApi()

    register : ({ realm, username, name }) ->
      return @registrationApi.register({ realm, username, name })

  return RegistrationClient
