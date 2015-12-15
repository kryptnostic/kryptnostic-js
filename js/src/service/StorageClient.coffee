define 'kryptnostic.storage-client', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.validators'
  'kryptnostic.object-api'
  'kryptnostic.object-listing-api'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.object-utils'
  'kryptnostic.search-indexing-service'
  'kryptnostic.create-object-request'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  # libraries
  Promise = require 'bluebird'

  # kryptnostic
  CreateObjectRequest   = require 'kryptnostic.create-object-request'
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  ObjectApi             = require 'kryptnostic.object-api'
  ObjectListingApi      = require 'kryptnostic.object-listing-api'
  SearchIndexingService = require 'kryptnostic.search-indexing-service'
  CredentialLoader      = require 'kryptnostic.credential-loader'

  # utils
  Logger      = require 'kryptnostic.logger'
  ObjectUtils = require 'kryptnostic.object-utils'
  validators  = require 'kryptnostic.validators'

  { validateId, validateNonEmptyString } = validators

  logger = Logger.get('StorageClient')

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  #
  class StorageClient

    constructor : ->
      logger.info 'storage client created'
      @objectApi             = new ObjectApi()
      @objectListingApi      = new ObjectListingApi()
      @cryptoServiceLoader   = CryptoServiceLoader.get()
      @searchIndexingService = new SearchIndexingService()
      @credentialLoader      = new CredentialLoader()

    getOwnUuid : ->
      return @credentialLoader.getCredentials().principal

    getObjectIds : ->
      return @objectApi.getObjectIds()

    getObject : (id) ->
      return @objectApi.getObject(id)

    getVersionedObjectKey: (objectId) ->
      return @objectApi.getVersionedObjectKey(objectId)

    getObjectIdsByType : (type) ->
      { userId } = {}
      Promise.resolve()
      .then =>
        @getOwnUuid()
      .then (id) =>
        userId = id
        @objectListingApi.getTypeForName(type)
      .then (typeId) =>
        @objectListingApi.getObjectIdsByType(userId, typeId)
      .then (ids) ->
        return ids

    getObjectMetadata : (id) ->
      return @objectApi.getObjectMetadata(id)

    deleteObject : (id) ->
      return @objectApi.deleteObject(id)

    getObjectAsBlockCiphertext: (versionedObjectKey) ->
      return @objectApi.getObjectAsBlockCiphertext(versionedObjectKey)

    uploadObject : (storageRequest, objectSearchPair) ->
      { objectIdPair, objectKey } = {}

      Promise.resolve()
      .then ->
        storageRequest.validate()
      .then =>
        @objectListingApi.getTypeForName(storageRequest.type)
      .then (typeUuid) =>
        createObjectRequest = new CreateObjectRequest({
          type: typeUuid
          requiredCryptoMats: [ 'IV', 'CONTENTS' ]
        })
        if storageRequest.parent?
          createObjectRequest.parentObjectId = storageRequest.parent
        @objectApi.createObject(createObjectRequest)
      .then (versionedObjectKey) =>
        objectKey = versionedObjectKey
        objectIdPair = {
          objectId       : objectKey.objectId
          parentObjectId : if storageRequest.parent then storageRequest.parent.objectId else objectKey.objectId
        }
        @cryptoServiceLoader.getObjectCryptoService(
          objectIdPair.parentObjectId,
          { expectMiss : true }
        )
      .then (cryptoService) =>
        { body } = storageRequest
        objectId = objectIdPair.objectId
        @encrypt({ objectId, body, cryptoService })
      .then (encrypted) =>
        # @submitObjectBlocks(encrypted)
        blockCiphertext = encrypted.body.data[0].block
        @objectApi.setObjectFromBlockCiphertext(objectKey, blockCiphertext)
      .then =>
        @searchIndexingService.submit({ storageRequest, objectIdPair, objectSearchPair })
      .then (objectSearchPair) ->
        return {
          objectKey
          objectIdPair
          objectSearchPair
        }

    encrypt : ({ objectId, body, cryptoService }) ->
      kryptnosticObject = KryptnosticObject.createFromDecrypted({
        id: objectId,
        body: body
      })
      return kryptnosticObject.encrypt(cryptoService)

    # submitObjectBlocks : (kryptnosticObject) ->
    #   Promise.resolve()
    #   .then =>
    #     kryptnosticObject.validateEncrypted()
    #
    #     objectId        = kryptnosticObject.metadata.id
    #     encryptedBlocks = kryptnosticObject.body.data
    #
    #     Promise.reduce(encryptedBlocks, (chain, nextEncryptableBlock) =>
    #       return Promise.resolve(chain)
    #         .then => @objectApi.updateObject(objectId, nextEncryptableBlock)
    #     , Promise.resolve())

  return StorageClient
