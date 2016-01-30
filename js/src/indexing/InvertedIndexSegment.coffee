define 'kryptnostic.indexing.inverted-index-segment', [
  'require',
  'kryptnostic.schema.inverted-index-segment',
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA    = require 'kryptnostic.schema.inverted-index-segment'
  Validator = require 'kryptnostic.schema.validator'

  class InvertedIndexSegment

    constructor: (properties) ->
      _.extend(this, properties)
      @validate()

    validate : ->
      Validator.validate(this, InvertedIndexSegment, SCHEMA)

  return InvertedIndexSegment
