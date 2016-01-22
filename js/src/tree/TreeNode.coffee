define 'kryptnostic.tree-node', [
  'require'
  'bluebird'
  'lodash'
  'kryptnostic.logger'
  'kryptnostic.object-utils'
], (require) ->

  _           = require 'lodash'
  Promise     = require 'bluebird'
  Logger      = require 'kryptnostic.logger'
  ObjectUtils = require 'kryptnostic.object-utils'

  log = Logger.get('TreeNode')

  validateId = (id) ->
    if _.isEmpty(id)
      errMsg = 'illegal TreeNode - no id provided'
      log.error(errMsg)
      throw new Error(errMsg)
    if not _.isString(id)
      errMsg = 'illegal TreeNode - id must be a String'
      log.error(errMsg, { id })
      throw new Error(errMsg)

  validateChildren = (children) ->
    unless _.isObject(children)
      errMsg = 'illegal TreeNode - children must be an Object'
      throw new Error(errMsg)
    # children.forEach (child) ->
    #   unless child.constructor.name is 'TreeNode'
    #     throw new Error 'child must be a tree node'

  class TreeNode

    constructor: (@objectMetadataTree = {}) ->
      validateId(@objectMetadataTree.metadata.id)
      validateChildren(@objectMetadataTree.children)

    # visits children depth-first and then the root node
    visit : (visitor) ->

      childPromises = _.map(@objectMetadataTree.children, (child) ->
        childNode = new TreeNode(child)
        return childNode.visit(visitor)
      )

      Promise.all(childPromises)
      .then =>
        return visitor.visit(@objectMetadataTree)

  return TreeNode
