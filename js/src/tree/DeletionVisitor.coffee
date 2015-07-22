define 'soteria.deletion-visitor', [
  'require'
  'bluebird'
  'soteria.logger'
  'soteria.storage-client'
], (require) ->

  Promise       = require 'bluebird'
  Logger        = require 'soteria.logger'
  StorageClient = require 'soteria.storage-client'

  log = Logger.get('DeletionVisitor')

  #
  # Permanently deletes all objects in a tree.
  # Author: rbuckheit
  #
  class DeletionVisitor

    constructor: ->
      @storageClient = new StorageClient()
      @deleted       = []

    visit: (id) ->
      log.info('visit', id)
      Promise.resolve()
      .then =>
        @storageClient.deleteObject(id)
      .then =>
        @deleted.push(id)

  return DeletionVisitor
