define 'kryptnostic.permission-change-visitor', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.validators'
  'kryptnostic.storage-client'
  'kryptnostic.sharing-client'
], (require) ->

  Promise       = require 'bluebird'
  Logger        = require 'kryptnostic.logger'
  validators    = require 'kryptnostic.validators'
  SharingClient = require 'kryptnostic.sharing-client'

  ObjectAuthorizationApi = require 'kryptnostic.object-authorization-api'

  log = Logger.get('PermissionChangeVisitor')

  { validateId } = validators

  #
  # Changes permissions on the visited object nodes.
  # Author: rbuckheit
  #
  class PermissionChangeVisitor

    constructor: (@uuids) ->
      @objectAuthApi = new ObjectAuthorizationApi()
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

    getParticipants: (objectId) ->
      Promise.resolve()
      .then =>
        validateId(objectId)
        Promise.props({
          owners  : @objectAuthApi.getUsersWithOwnerAccess(objectId)
          readers : @objectAuthApi.getUsersWithReadAccess(objectId)
          writers : @objectAuthApi.getUsersWithWriteAccess(objectId)
        })
      .then ({ owners, readers, writers }) =>
        uuids = _.chain([owners, readers, writers])
          .flatten()
          .unique()
          .value()
        return uuids
