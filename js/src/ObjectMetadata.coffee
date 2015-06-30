define 'soteria.object-metadata', [
  'require'
  'lodash'
  'revalidator'
], (require) ->
  'use strict'

  _           = require 'lodash'
  revalidator = window # TODO: gross

  # TODO make strict
  SCHEMA = {
    properties: {
      id               : { type: 'string' }
      type             : { type: 'string' }
      timeCreated      : { type: 'number' }
      version          : { type: 'number' }
      total            : { type: 'number' }
      childObjectCount : { type: 'number' }
      strategy         : { type: 'string' }
      owners           : { type: 'array' }
      readers          : { type: 'array' }
      writers          : { type: 'array' }
      name             : {
        type        : 'object'
        description : 'encrypted class name'
        properties : {
          iv       : {type: 'string'}
          salt     : {type:'string'}
          contents : {type: 'string'}
        }
      }
    }
  }

  getDefaultOpts = ->
    return {
      timeCreated      : new Date().getTime()
      version          : 0
      total            : 0
      childObjectCount : 0
      strategy         : 'soteria.chunking.strategy.default'
      owners           : []
      readers          : []
      writers          : []
      name             : {}
    }

  class ObjectMetadata

    constructor : (opts) ->
      _.extend(this, opts, getDefaultOpts())
      @validate()

    validate : =>
      unless this instanceof ObjectMetadata
        return

      validation = revalidator.validate(this, SCHEMA)
      if not validation.valid
        console.error('object metadata failed validation' + JSON.stringify(validation))
        console.info(JSON.stringify(this))
        throw new Error('illegal ObjectMetadata arguments')


