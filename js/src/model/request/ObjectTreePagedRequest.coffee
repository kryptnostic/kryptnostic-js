define 'kryptnostic.object-tree-paged-request', [
  'require'
  'kryptnostic.schema.validator'
], (require) ->

  SCHEMA       = require 'kryptnostic.schema.object-tree-paged-request'
  validator    = require 'kryptnostic.schema.validator'

  DEFAULT_OPTS = {}

  class ObjectTreePagedRequest

    constructor: (opts) ->
      _.extend(this, DEFAULT_OPTS, opts)
      @validate()

    validate : ->
      validator.validate(this, ObjectTreePagedRequest, SCHEMA)

    getRequestData: ->

      requestData = {}
      requestData.depth = @loadDepth
      requestData.scrollSize = @pageSize
      requestData.loadLevels = @typeLoadLevels

      if not _.isEmpty(@objectIdsToFilter)
        requestData.objectIdsToFilter = @objectIdsToFilter

      return requestData

  return ObjectTreePagedRequest
