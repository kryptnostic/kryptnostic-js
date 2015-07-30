define 'kryptnostic.object-metadata', [
  'require'
  'lodash'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.object-metadata'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'kryptnostic.schema.validator'
  SCHEMA    = require 'kryptnostic.schema.object-metadata'

  getDefaultOpts = ->
    return {
      timeCreated      : new Date().getTime()
      version          : 0
      total            : 0
      childObjectCount : 0
      owners           : []
      readers          : []
      writers          : []
      name             : {}
      strategy         : {
        '@class' : 'com.kryptnostic.kodex.v1.serialization.crypto.DefaultChunkingStrategy'
      }
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
