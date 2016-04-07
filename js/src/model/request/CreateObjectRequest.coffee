define 'kryptnostic.create-object-request', [
  'require'
  'lodash'
  'kryptnostic.schema.create-object-request'
  'kryptnostic.schema.validator'
], (require) ->

  _            = require 'lodash'
  SCHEMA       = require 'kryptnostic.schema.create-object-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = { cypher: 'AES_GCM_128' }

  class CreateObjectRequest

    constructor: (properties) ->
      _.extend(this, DEFAULT_OPTS, properties)
      @validate()

    validate : ->
      validator.validate(this, CreateObjectRequest, SCHEMA)

  return CreateObjectRequest
