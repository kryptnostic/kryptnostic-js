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
      log.error('illegal id argument', {id})
      throw new Error 'illegal id argument'

  #
  # Changes permissions on the visited object nodes.
  # Author: rbuckheit
  #
  class PermissionChangeVisitor

    constructor: (@users) ->
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
        log.error('failed to change permissions', {id})
        log.error('error', _.extend({}, e, {msg: e.message, stack: e.stack}))
        @failed.push(id)

    changePermissions: (id) ->
      {usersAdd, usersRemove} = {}

      Promise.resolve()
      .then =>
        validateId(id)
        @getParticipants(id)
      .then (current) =>
        usersAdd    = _.difference(@users, current)
        usersRemove = _.difference(current, @users)
        log.info('changePermissions', {id, usersRemove, usersAdd})
      .then =>
        @sharingClient.revokeObject(id, usersRemove)
      .then =>
        @sharingClient.shareObject(id, usersAdd)
      .then =>
        @changedUsers[id] = { addedUsers: usersAdd, removedUsers: usersRemove }

    getParticipants: (id) ->
      Promise.resolve()
      .then =>
        validateId(id)
        @storageClient.getObjectMetadata(id)
      .then (metadata) ->
        usernames = _.chain([metadata.owners, metadata.readers, metadata.writers])
          .flatten()
          .pluck('name')
          .unique()
          .value()

        return usernames
