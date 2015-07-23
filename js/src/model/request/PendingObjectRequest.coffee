define 'kryptnostic.pending-object-request', [
  'require'
  'lodash'
  'kryptnostic.schema.pending-object-request'
  'kryptnostic.schema.validator'
], (require) ->

  _         = require 'lodash'
  SCHEMA    = require 'kryptnostic.schema.pending-object-request'
  validator = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  #
  # JSON request to create a pending object in Kryptnostic services.
  # Author: rbuckheit
  #
  class PendingObjectRequest

    constructor : (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, PendingObjectRequest, SCHEMA)

  return PendingObjectRequest
