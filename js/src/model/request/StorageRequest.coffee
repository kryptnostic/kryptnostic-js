define 'soteria.storage-request', [
  'require'
  'lodash'
  'soteria.schema.storage-request'
  'soteria.schema.validator'
], (require) ->

  _            = require 'lodash'
  SCHEMA       = require 'soteria.schema.storage-request'
  validator    = require 'soteria.schema.validator'

  DEFAULT_OPTS = { type: 'object', version: 0 }

  #
  # JSON request to store an object in Kryptnostic services.
  # Author: rbuckheit
  #
  class StorageRequest

    constructor: (opts) ->
      _.extend(this, opts, DEFAULT_OPTS)
      @validate()

    validate : ->
      validator.validate(this, StorageRequest, SCHEMA)

  return StorageRequest
