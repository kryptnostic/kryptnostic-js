define 'kryptnostic.indexed-metadata', [
  'require'
  'lodash'
  'kryptnostic.schema.indexed-metadata'
  'kryptnostic.schema.validator'
], (require) ->

  _         = require 'lodash'
  SCHEMA    = require 'kryptnostic.schema.indexed-metadata'
  validator = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  #
  # JSON request to for a piece of indexed metadata in Kryptnostic services.
  # Author: rbuckheit
  #
  class IndexedMetadata

    constructor : (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, IndexedMetadata, SCHEMA)

  return IndexedMetadata
