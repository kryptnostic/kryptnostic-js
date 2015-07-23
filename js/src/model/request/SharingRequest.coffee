define 'kryptnostic.sharing-request', [
  'require'
  'lodash'
  'kryptnostic.schema.sharing-request'
  'kryptnostic.schema.validator'
], (require) ->

  _         = require 'lodash'
  SCHEMA    = require 'kryptnostic.schema.sharing-request'
  validator = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  #
  # JSON request to share an object in Kryptnostic services.
  # Author: rbuckheit
  #
  class SharingRequest

    constructor : (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, SharingRequest, SCHEMA)

  return SharingRequest
