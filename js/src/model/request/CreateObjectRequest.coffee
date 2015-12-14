define 'kryptnostic.create-object-request', [
  'require'
  'lodash'
  'kryptnostic.schema.create-object-request'
  'kryptnostic.schema.validator'
], (require) ->

  _            = require 'lodash'
  SCHEMA       = require 'kryptnostic.schema.create-object-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = { type: 'object' }

  class CreateObjectRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, CreateObjectRequest, SCHEMA)

  return CreateObjectRequest
