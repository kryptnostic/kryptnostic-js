define 'kryptnostic.search-request', [
  'require'
  'kryptnostic.schema.search-request'
  'kryptnostic.schema.validator'
], (require) ->

  # schema
  SCHEMA    = require 'kryptnostic.schema.search-request'

  # utils
  Validator = require 'kryptnostic.schema.validator'

  class SearchRequest

    constructor : (options) ->
      _.extend(this, options)
      @validate()

    validate : ->
      Validator.validate(this, SearchRequest, SCHEMA)

  return SearchRequest
