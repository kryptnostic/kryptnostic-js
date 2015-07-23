define 'kryptnostic.tree-loader', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.tree-node'
  'kryptnostic.object-api'
  'kryptnostic.object-utils'
], (require) ->

  ObjectApi   = require 'kryptnostic.object-api'
  ObjectUtils = require 'kryptnostic.object-utils'
  TreeNode    = require 'kryptnostic.tree-node'
  Logger      = require 'kryptnostic.logger'
  Promise     = require 'bluebird'

  log = Logger.get('TreeLoader')

  #
  # Loads the ID's in a Kryptnostic object tree.
  # Author: rbuckheit
  #
  class TreeLoader

    constructor: ->
      @objectApi = new ObjectApi()

    load: (id) ->
      log.info('load', id)

      return Promise.resolve()
      .then =>
        @objectApi.getObjectMetadata(id)
      .then (metadata) =>
        {childObjectCount} = metadata
        childIndices       = [0...childObjectCount]
        return Promise.all(_.map(childIndices, (index) =>
          childId = ObjectUtils.createChildId(id, index)
          return @load(childId)
        ))
      .then (children) ->
        children = _.compact(children)
        return new TreeNode(id, children)
      .catch (e) ->
        {message, stack} = e
        log.error('failed to load', {e, message, stack})
        return undefined

  return TreeLoader
