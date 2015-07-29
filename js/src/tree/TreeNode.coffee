define 'kryptnostic.tree-node', [
  'require'
  'bluebird'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  _       = require 'lodash'
  Promise = require 'bluebird'
  Logger  = require 'kryptnostic.logger'

  log = Logger.get('TreeNode')

  validateId = (id) ->
    if _.isEmpty(id)
      throw new Error 'no root id provided'
    if not _.isString(id)
      throw new Error 'id is not a string'

  validateChildren = (children) ->
    unless _.isArray(children)
      throw new Error 'children must be an array'
    children.forEach (child) ->
      unless child.constructor.name is 'TreeNode'
        throw new Error 'child must be a tree node'

  #
  # Represents a node in a tree of Kryptnostic objects.
  # Author: rbuckheit
  #
  class TreeNode

    constructor: (@id, @children = []) ->
      log.info('construct', { @id, @children })

      validateId(@id)
      validateChildren(@children)

    # visits children depth-first and then the root node
    visit : (visitor) ->
      log.info('visit root')
      Promise.all(_.map(@children, (child) ->
        log.info('visit child', child)
        return child.visit(visitor)
      ))
      .then =>
        log.info('visit', @id)
        return visitor.visit(@id)

  return TreeNode
