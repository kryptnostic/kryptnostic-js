define 'kryptnostic.object-tree-request', [
  'require'
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA       = require 'kryptnostic.schema.object-tree-request'
  Validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  class ObjectTreeRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      Validator.validate(this, ObjectTreeRequest, SCHEMA)

    getRequestData: ->

      requestData = {}
      requestData.objectIds = [@rootObjectKey.objectId]
      requestData.depth = @loadDepth
      requestData.loadLevels = @typeLoadLevels

      return requestData

  return ObjectTreeRequest
