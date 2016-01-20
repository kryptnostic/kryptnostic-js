define 'kryptnostic.object-tree-load-request', [
  'require'
  'kryptnostic.schema.create-object-request'
  'kryptnostic.schema.validator'
], (require) ->

  _            = require 'lodash'
  SCHEMA       = require 'kryptnostic.schema.object-tree-load-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  class ObjectTreeLoadRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, ObjectTreeLoadRequest, SCHEMA)

  return ObjectTreeLoadRequest
