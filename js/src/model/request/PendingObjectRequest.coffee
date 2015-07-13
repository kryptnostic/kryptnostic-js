define 'soteria.pending-object-request', [
  'require'
  'lodash'
  'soteria.schema.pending-object-request'
  'soteria.schema.validator'
], (require) ->

  _         = require 'lodash'
  SCHEMA    = require 'soteria.schema.pending-object-request'
  validator = require 'soteria.schema.validator'

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
