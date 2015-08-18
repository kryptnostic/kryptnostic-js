define 'kryptnostic.user-registration-request', [
  'require'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.user-registration-request'
], (require) ->

  validator = require 'kryptnostic.schema.validator'
  SCHEMA = require 'kryptnostic.schema.user-registration-request'

  #
  # HTTP request format for registering a new kryptnostic user.
  # Author: rbuckheit
  #

  DEFAULTS = { confirmationEmailNeeded: false }

  class UserRegistrationRequest

    constructor: ({ @password, @email, @name, @confirmationEmailNeeded }) ->
      _.defaults(this, DEFAULTS)

    validate: ->
      validator.validate(this, UserRegistrationRequest, SCHEMA)

  return UserRegistrationRequest
