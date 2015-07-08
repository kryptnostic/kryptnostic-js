define 'soteria.object-metadata', [
  'require'
  'lodash'
  'soteria.schema.validator'
  'soteria.schema.object-metadata'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'soteria.schema.validator'
  SCHEMA    = require 'soteria.schema.object-metadata'

  getDefaultOpts = ->
    return {
      timeCreated      : new Date().getTime()
      version          : 0
      total            : 0
      childObjectCount : 0
      strategy         : {'@class' : 'soteria.chunking.strategy.default'}
      owners           : []
      readers          : []
      writers          : []
      name             : {}
    }

  #
  # Representation of metadata for a KryptnosticObject.
  # Author: rbuckheit
  #
  class ObjectMetadata

    constructor : (opts) ->
      _.extend(this, getDefaultOpts(), opts)
      @validate()

    validate : =>
      validator.validate(this, ObjectMetadata, SCHEMA)

  return ObjectMetadata
