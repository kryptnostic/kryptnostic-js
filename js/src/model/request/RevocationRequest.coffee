define 'kryptnostic.revocation-request', [
  'require'
  'lodash'
  'kryptnostic.schema.revocation-request'
  'kryptnostic.schema.validator'
], (require) ->

  _         = require 'lodash'
  SCHEMA    = require 'kryptnostic.schema.revocation-request'
  validator = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  #
  # JSON request to revoke access to an object in Kryptnostic services.
  # Author: rbuckheit
  #
  class RevocationRequest

    constructor : (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, RevocationRequest, SCHEMA)

  return RevocationRequest
