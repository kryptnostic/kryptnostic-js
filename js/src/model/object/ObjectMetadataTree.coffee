define 'kryptnostic.object-metadata-tree', [
  'require'
  'lodash'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.object-metadata-tree'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'kryptnostic.schema.validator'
  SCHEMA    = require 'kryptnostic.schema.object-metadata-tree'

  class ObjectMetadataTree

    constructor : (obj) ->
      _.extend(this, {}, obj)
      @validate()

    validate : =>
      validator.validate(this, ObjectMetadataTree, SCHEMA)

  return ObjectMetadataTree
