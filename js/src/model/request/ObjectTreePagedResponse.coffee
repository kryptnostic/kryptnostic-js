define 'kryptnostic.object-tree-paged-response', [
  'require'
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA       = require 'kryptnostic.schema.object-tree-paged-response'
  Validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  class ObjectTreePagedResponse

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      Validator.validate(this, ObjectTreePagedResponse, SCHEMA)

  return ObjectTreePagedResponse
