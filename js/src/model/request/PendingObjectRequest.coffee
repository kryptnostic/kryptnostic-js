define 'soteria.pending-object-request', [
  'require'
  'lodash'
  'revalidator'
  'soteria.schema.pending-object-request'
], (require) ->

  _            = require 'lodash'
  SCHEMA       = require 'soteria.schema.pending-object-request'
  revalidator  = window  # TODO : gross

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