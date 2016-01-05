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
  validators  = require 'kryptnostic.validators'

  { validateUuid } = validators

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


    getObject : (id) ->
      throw new Error('StorageClient:getObject() is deprecated')

    getObjectIds : ->
      throw new Error('StorageClient:getObjectIds() is deprecated')

    getObjectMetadata : (id) ->
      throw new Error('StorageClient:getObjectMetadata() is deprecated')

    deleteObject : (id) ->
      throw new Error('StorageClient:deleteObject() is deprecated')

    storeObject: (storageRequest, objectSearchPair) ->

      storageRequest.validate()
      storageResponse = {}

      typeIdPromise = null
      if validateUuid(storageRequest.typeId)
        typeIdPromise = Promise.resolve(storageRequest.typeId)
      else
        typeIdPromise = @objectListingApi.getTypeIdForTypeName(storageRequest.typeName)

      parentObjectKeyPromise = null
      if validateUuid(storageRequest.parentId)
        parentObjectKeyPromise = @objectApi.getVersionedObjectKey(storageRequest.parentId)

      Promise.join(
        typeIdPromise,
        parentObjectKeyPromise,
        (typeId, parentObjectKey) =>

          createObjectRequest = new CreateObjectRequest({
            type: typeId
            requiredCryptoMats: [ 'IV', 'CONTENTS' ]
          })

          if parentObjectKey?
            createObjectRequest.parentObjectId = parentObjectKey

          Promise.resolve(
            @objectApi.createObject(createObjectRequest)
          )
          .then (versionedObjectKey) =>
            parentObjectId = if storageRequest.parentId then storageRequest.parentId else versionedObjectKey.objectId
            Promise.resolve(
              @cryptoServiceLoader.getObjectCryptoServiceV2(
                parentObjectId,
                { expectMiss : true }
              )
            )
            .then (cryptoService) =>
              @encrypt(versionedObjectKey.objectId, storageRequest.body, cryptoService)
            .then (encrypted) =>
              # for now, we'll encrypt the entire object, but we'll need to support encrypting an object in chunks
              # @submitObjectBlocks(encrypted)
              blockCiphertext = encrypted.body.data[0].block
              @objectApi.setObjectFromBlockCiphertext(versionedObjectKey, blockCiphertext)
            .then =>
              objectIdPair = {
                objectId       : versionedObjectKey.objectId,
                parentObjectId : parentObjectId
              }
              @searchIndexingService.submit({ storageRequest, objectIdPair, objectSearchPair })
            .then (objectSearchPair) ->
              storageResponse.objectKey = versionedObjectKey
              storageResponse.objectSearchPair = objectSearchPair
              storageResponse.parentObjectId = parentObjectId
              return storageResponse
      )

    encrypt : (objectId, body, cryptoService) ->
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
