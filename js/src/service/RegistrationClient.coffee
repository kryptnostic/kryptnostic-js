define 'kryptnostic.registration-client', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.registration-api'
], (require) ->
  'use strict'

  Promise         = require 'bluebird'
  Logger          = require 'kryptnostic.logger'
  RegistrationApi = require 'kryptnostic.registration-api'

  log = Logger.get('RegistrationClient')

  #
  # Allows user to register for a new account.
  #
  class RegistrationClient

    constructor : ->
      @registrationApi = new RegistrationApi()

    register : (realm, email, givenName) ->
      return @registrationApi.register(realm, email, givenName)   

  return RegistrationClient
