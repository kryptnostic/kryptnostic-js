'use strict'

#
# Demo script which loads and stores kryptnostic objects as a smoke test of functionality.
# All modules required are loaded from the built kryptnostic.js.
#
# Author: rbuckheit
#

renderObject = (kryptnosticObject) ->
  _.first(document.getElementsByClassName('kryptnostic-object')).innerHTML =
    JSON.stringify(kryptnosticObject, null, 2)

require [
  'require'
  'bluebird'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.storage-client'
  'kryptnostic.storage-request'
  'kryptnostic.permission-change-visitor'
  'kryptnostic.sharing-client'
  'kryptnostic.configuration'
  'kryptnostic.authentication-service'
  'kryptnostic.tree-loader'
  'kryptnostic.deletion-visitor'
], (require) ->

  Promise                 = require 'bluebird'
  CryptoServiceLoader     = require 'kryptnostic.crypto-service-loader'
  StorageClient           = require 'kryptnostic.storage-client'
  StorageRequest          = require 'kryptnostic.storage-request'
  SharingClient           = require 'kryptnostic.sharing-client'
  Config                  = require 'kryptnostic.configuration'
  AuthenticationService   = require 'kryptnostic.authentication-service'
  TreeLoader              = require 'kryptnostic.tree-loader'
  DeletionVisitor         = require 'kryptnostic.deletion-visitor'
  PermissionChangeVisitor = require 'kryptnostic.permission-change-visitor'
  UserDirectoryApi        = require 'kryptnostic.user-directory-api'

  cryptoServiceLoader = new CryptoServiceLoader()
  storageClient       = new StorageClient()
  sharingClient       = new SharingClient()
  treeLoader          = new TreeLoader()
  userDirectoryApi    = new UserDirectoryApi()

  # configure the client
  Config.set({
    servicesUrl : 'http://localhost:8081/v1',
    heraclesUrl : 'http://localhost:8082/v1'
  })

  USER1 = { email : 'demo@kryptnostic.com', password: 'demo' }
  USER2 = { email : 'test@kryptnostic.com', password: 'demo' }

  #
  # setup function which makes sure that both accounts are initialzed.
  # generates public keys for the users if needed.
  #
  setup = ->
    Promise.resolve()
    .then ->
      AuthenticationService.authenticate(USER1)
    .then ->
      AuthenticationService.destroy()
    .then ->
      AuthenticationService.authenticate(USER2)
    .then ->
      AuthenticationService.destroy()

  #
  # authenticate using a demo account
  #
  setup()
  .then ->
    AuthenticationService.authenticate(USER1)
  .then ->

    #
    # example 1
    # =========
    # encrypt an object, upload it, download it, and decrypt it.
    #
    storageRequest = new StorageRequest({ body : 'test message' })
    storageClient.uploadObject(storageRequest)
    .then (objectId) ->
      loadPromises = {
        kryptnosticObject : storageClient.getObject(objectId),
        cryptoService     : cryptoServiceLoader.getObjectCryptoService(objectId)
      }

      Promise.props(loadPromises)
      .then (result)  ->
        cryptoService     = result.cryptoService
        kryptnosticObject = result.kryptnosticObject
        decrypted         = kryptnosticObject.decrypt( cryptoService )
        renderObject(decrypted)
      .then ->
        storageClient.deleteObject(objectId)

    #
    # example 2
    # =========
    # create an object and share it with another user
    #
    userDirectoryApi.resolve({ email: 'test@kryptnostic.com' })
    .then (uuid) ->
      storageRequest = new StorageRequest({
        body : 'this message will be shared'
      })
      shareUsers = [ uuid ]

      storageClient.uploadObject(storageRequest)
      .then (objectId) ->
        sharingClient.shareObject(objectId, shareUsers)

    #
    # example 3
    # =========
    # change permissions on a whole tree of objects recursively
    #
    Promise.props({
      uuid      : userDirectoryApi.resolve({ email : 'demo@kryptnostic.com' })
      shareUuid : userDirectoryApi.resolve({ email : 'test@kryptnostic.com' })
    })
    .then ({ uuid, shareUuid }) ->
      { tree } = {}
      storageRequest = new StorageRequest({ body : 'this message will be shared' })
      addVisitor     = new PermissionChangeVisitor([ uuid, shareUuid ])
      removeVisitor  = new PermissionChangeVisitor([ uuid ])

      storageClient.uploadObject(storageRequest)
      .then (objectId) ->
        treeLoader.load(objectId)
      .then (_tree) ->
        tree = _tree
      .then ->
        tree.visit(addVisitor)
      .then ->
        tree.visit(removeVisitor)

    #
    # example 4
    # =========
    # delete an object and its children recursively
    #
    storageRequest = new StorageRequest({ body : 'this object and children will be deleted' })
    storageClient.uploadObject(storageRequest)
    .then (id) ->
      treeLoader.load(id)
    .then (tree) ->
      tree.visit(new DeletionVisitor())

