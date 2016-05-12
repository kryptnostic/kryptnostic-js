define 'kryptnostic.object-tree-response', [
  'require'
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA       = require 'kryptnostic.schema.object-tree-response'
  Validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  class ObjectTreeResponse

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      Validator.validate(this, ObjectTreeResponse, SCHEMA)

  return ObjectTreeResponse
