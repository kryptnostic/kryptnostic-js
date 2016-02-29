define 'kryptnostic.storage-request', [
  'require'
  'lodash'
  'kryptnostic.schema.storage-request'
  'kryptnostic.schema.validator'
], (require) ->

  _            = require 'lodash'
  SCHEMA       = require 'kryptnostic.schema.storage-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = { type: 'object', version: 0, cypher: 'AES_GCM_128' }

  #
  # JSON request to store an object in Kryptnostic services.
  # Author: rbuckheit
  #
  class StorageRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, StorageRequest, SCHEMA)

  return StorageRequest
