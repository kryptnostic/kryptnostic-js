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

  logger = Logger.get('TreeLoader')

  class TreeLoader

    constructor: ->
      @objectApi = new ObjectApi()

    loadTree: (objectIds, typeLoadLevels, loadDepth, createdAfter, objectIdsToFilter) ->
      Promise.resolve()
      .then =>
        @objectApi.getObjectsByTypeAndLoadLevel(
          objectIds,
          typeLoadLevels,
          loadDepth,
          createdAfter,
          objectIdsToFilter
        )
      .then (objectMetadataTrees) ->
        # objectMetadataTrees == Map<java.util.UUID, com.kryptnostic.v2.storage.models.ObjectMetadataEncryptedNode>
        objectTreeNodes = {}
        _.map(objectMetadataTrees, (node, objectId) ->
          if _.isObject(node)

            # sort children by timestamp
            sortedChildren = _.sortBy(node.children, (child) ->
              return child.metadata.timeCreated
            )
            _.map(sortedChildren, (child, index) ->
              parentObjectId = node.metadata.id
              nodeId = ObjectUtils.createChildId(parentObjectId, index)
              child.metadata.nodeId = nodeId
              return
            )
            objectTreeNodes[objectId] = new TreeNode(node)
        )
        return objectTreeNodes

    load: (id, { depth } = {}) ->
      throw new Error('TreeLoader:load() is deprecated')

  return TreeLoader
