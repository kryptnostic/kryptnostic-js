define 'kryptnostic.create-object-request', [
  'require'
  'lodash'
  'kryptnostic.cypher'
  'kryptnostic.schema.create-object-request'
  'kryptnostic.schema.validator'
], (require) ->

  _            = require 'lodash'
  Cypher       = require 'kryptnostic.cypher'
  SCHEMA       = require 'kryptnostic.schema.create-object-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = { cypher: Cypher.AES_GCM_256.toString() }

  class CreateObjectRequest

    constructor: (properties) ->
      _.extend(this, DEFAULT_OPTS, properties)
      @validate()

    validate : ->
      validator.validate(this, CreateObjectRequest, SCHEMA)

  return CreateObjectRequest
