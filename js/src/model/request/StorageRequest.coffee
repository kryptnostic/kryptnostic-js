define 'kryptnostic.storage-request', [
  'require'
  'lodash'
  'kryptnostic.cypher'
  'kryptnostic.schema.storage-request'
  'kryptnostic.schema.validator'
], (require) ->

  _            = require 'lodash'
  Cypher       = require 'kryptnostic.cypher'
  SCHEMA       = require 'kryptnostic.schema.storage-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = { type: 'object', version: 0, cypher: Cypher.AES_GCM_256.toString() }

  class StorageRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, StorageRequest, SCHEMA)

  return StorageRequest
