define 'kryptnostic.registration-service', [
  'require'
  'bluebird'
  'kryptnostic.logger'
], (require) ->
  'use strict'

  Promise = require 'bluebird'
  Logger  = require 'kryptnostic.logger'

  log = Logger.get('RegistrationClient')

  #
  # Allows user to register for a new account.
  #
  class RegistrationClient
