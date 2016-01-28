define 'kryptnostic.indexing.bucketed-metadata', [
  'require',
  'kryptnostic.schema.bucketed-metadata',
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA    = require 'kryptnostic.schema.bucketed-metadata'
  Validator = require 'kryptnostic.schema.validator'

  class BucketedMetadata

    constructor: (properties) ->
      _.extend(this, properties)
      @validate()

    validate : ->
      Validator.validate(this, BucketedMetadata, SCHEMA)

  return BucketedMetadata
