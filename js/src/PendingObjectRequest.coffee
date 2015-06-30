define 'soteria.pending-object-request', [
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
      parentObjectId : {
        description : 'id of the parent object if creating a child object'
        type        : 'number'
        required    : false
        allowEmpty  : false
      }
    }
  }

  DEFAULT_OPTS = {}


  class PendingObjectRequest

    constructor : (opts) ->
      console.info('construct from opts', JSON.stringify(opts))
      _.extend(this, opts, DEFAULT_OPTS)
      @validate()

    validate : () ->
      unless this instanceof PendingObjectRequest
        return

      validation = revalidator.validate(this, SCHEMA)
      if not validation.valid
        console.error('pending object request validation failed', JSON.stringify(validation,null,2))
        console.error(JSON.stringify(this))
        throw new Error 'illegal pending object request'


  return PendingObjectRequest