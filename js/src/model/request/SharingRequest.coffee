define 'soteria.sharing-request', [
  'require'
  'lodash'
  'soteria.schema.pending-object-request'
  'soteria.schema.validator'
], (require) ->

  _         = require 'lodash'
  SCHEMA    = require 'soteria.schema.sharing-request'
  validator = require 'soteria.schema.validator'

  DEFAULT_OPTS = {}

  #
  # JSON request to share an object in Kryptnostic services.
  # Author: rbuckheit
  #
  class SharingRequest

    constructor : (opts) ->
      _.extend(this, opts, DEFAULT_OPTS)
      @validate()

    validate : () ->
      validator.validate(this, SharingRequest, SCHEMA)

  return SharingRequest
