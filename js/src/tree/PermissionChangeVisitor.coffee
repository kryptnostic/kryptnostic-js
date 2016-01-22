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

    visit: (objectMetadataTree) ->
      objectId = objectMetadataTree.metadata.id
      Promise.resolve()
      .then =>
        @changePermissions(objectMetadataTree)
      .then =>
        @changed.push(objectId)
      .catch (e) =>
        log.error('failed to change permissions', { objectId })
        log.error('error', _.extend({}, e, { msg: e.message, stack: e.stack }))
        @failed.push(objectId)

    changePermissions: (objectMetadataTree) ->
      { uuidsAdd, uuidsRemove } = {}
      objectId = objectMetadataTree.metadata.id
      Promise.resolve(
        @getParticipants(objectMetadataTree)
      )
      .then (current) =>
        uuidsAdd    = _.difference(@uuids, current)
        uuidsRemove = _.difference(current, @uuids)
        log.info('changePermissions', { objectId, uuidsRemove, uuidsAdd })
      .then =>
        @sharingClient.revokeObject(objectId, uuidsRemove)
      .then =>
        @sharingClient.shareObject(objectId, uuidsAdd)
      .then =>
        @changedUsers[objectId] = { added: uuidsAdd, removed: uuidsRemove }

    getParticipants: (objectMetadataTree) ->
      objectId = objectMetadataTree.metadata.id
      Promise.props({
        owners  : @objectAuthApi.getUsersWithOwnerAccess(objectId)
        readers : @objectAuthApi.getUsersWithReadAccess(objectId)
        writers : @objectAuthApi.getUsersWithWriteAccess(objectId)
      })
      .then ({ owners, readers, writers }) ->
        uuids = _.chain([owners, readers, writers])
          .flatten()
          .unique()
          .value()
        return uuids
