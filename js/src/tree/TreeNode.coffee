define 'kryptnostic.tree-node', [
  'require'
  'bluebird'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  _           = require 'lodash'
  Promise     = require 'bluebird'
  Logger      = require 'kryptnostic.logger'

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
