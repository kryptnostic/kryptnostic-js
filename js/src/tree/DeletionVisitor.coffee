define 'kryptnostic.deletion-visitor', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.storage-client'
], (require) ->

  Promise       = require 'bluebird'
  Logger        = require 'kryptnostic.logger'
  ObjectApi     = require 'kryptnostic.object-api'

  log = Logger.get('DeletionVisitor')

  class DeletionVisitor

    constructor: ->
      @objectApi     = new ObjectApi()
      @deleted       = []

    visit: (id) ->
      log.info('visit', id)
      Promise.resolve()
      .then =>
        @objectApi.deleteObject(id)
      .then =>
        @deleted.push(id)

  return DeletionVisitor
