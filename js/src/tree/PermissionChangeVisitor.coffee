define 'kryptnostic.permission-change-visitor', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.storage-client'
  'kryptnostic.sharing-client'
], (require) ->

  Promise       = require 'bluebird'
  Logger        = require 'kryptnostic.logger'
  StorageClient = require 'kryptnostic.storage-client'
  SharingClient = require 'kryptnostic.sharing-client'

  log = Logger.get('PermissionChangeVisitor')

  validateId = (id) ->
    unless _.isString(id) and not _.isEmpty(id)
      log.error('illegal id argument', { id })
      throw new Error 'illegal id argument'

  #
  # Changes permissions on the visited object nodes.
  # Author: rbuckheit
  #
  class PermissionChangeVisitor

    constructor: (@uuids) ->
      @storageClient = new StorageClient()
      @sharingClient = new SharingClient()
      @changed       = []
      @failed        = []
      @changedUsers  = {}

    visit: (id) ->
      Promise.resolve()
      .then =>
        validateId(id)
        @changePermissions(id)
      .then =>
        @changed.push(id)
      .catch (e) =>
        log.error('failed to change permissions', { id })
        log.error('error', _.extend({}, e, { msg: e.message, stack: e.stack }))
        @failed.push(id)

    changePermissions: (id) ->
      { uuidsAdd, uuidsRemove } = {}

      Promise.resolve()
      .then =>
        validateId(id)
        @getParticipants(id)
      .then (current) =>
        uuidsAdd    = _.difference(@uuids, current)
        uuidsRemove = _.difference(current, @uuids)
        log.info('changePermissions', { id, uuidsRemove, uuidsAdd })
      .then =>
        @sharingClient.revokeObject(id, uuidsRemove)
      .then =>
        @sharingClient.shareObject(id, uuidsAdd)
      .then =>
        @changedUsers[id] = { added: uuidsAdd, removed: uuidsRemove }

    getParticipants: (id) ->
      Promise.resolve()
      .then =>
        validateId(id)
        @storageClient.getObjectMetadata(id)
      .then (metadata) ->
        uuids = _.chain([metadata.owners, metadata.readers, metadata.writers])
          .flatten()
          .unique()
          .value()

        return uuids
