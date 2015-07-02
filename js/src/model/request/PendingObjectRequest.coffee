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

  class PendingObjectRequest

    constructor : (opts) ->
      _.extend(this, opts, DEFAULT_OPTS)
      @validate()

    validate : () ->
      validator.validate(this, PendingObjectRequest, SCHEMA)

  return PendingObjectRequest
