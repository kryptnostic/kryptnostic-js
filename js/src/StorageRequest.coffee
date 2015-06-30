define 'soteria.storage-request', [
  'require'
  'lodash'
  'revalidator'
], (require) ->

  _           = require 'lodash'
  revalidator = window # TODO : gross

  SCHEMA = {
    properties: {
      type : {
        description : 'the type of object being stored'
        type        : 'string'
        required    : true
        allowEmpty  : false
      },
      objectId : {
        description : 'preset object id if overwriting another object'
        type        : 'number'
        required    : false
        allowEmpty  : false
      },
      parentObjectId : {
        description : 'id of the parent object if creating a child object'
        type        : 'number'
        required    : false
        allowEmpty  : false
      }
      body : {
        description : 'content to be encrypted'
        type        : 'string'
        required    : true
        allowEmpty  : false
      }
    }
  }

  DEFAULT_OPTS = {type: 'object', version: 0}

  class StorageRequest

    constructor: (opts) ->
      _.extend(this, opts, DEFAULT_OPTS)
      @validate()

    validate : ->
      validation = revalidator.validate(this, SCHEMA)

      if not validation.valid
        console.error('storage request validation failed', validation)
        throw new Error 'illegal storage request'

  # return StorageRequest