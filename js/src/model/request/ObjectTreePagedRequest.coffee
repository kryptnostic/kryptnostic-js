define 'kryptnostic.object-tree-paged-request', [
  'require'
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA       = require 'kryptnostic.schema.object-tree-paged-request'
  Validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  class ObjectTreePagedRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      Validator.validate(this, ObjectTreePagedRequest, SCHEMA)

    getRequestData: ->

      requestData = {}
      requestData.depth = @loadDepth
      requestData.pageSize = @pageSize
      requestData.loadLevels = @typeLoadLevels

      return requestData

  return ObjectTreePagedRequest
