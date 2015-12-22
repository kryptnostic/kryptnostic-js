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


    getObject : (id) ->
      throw new Error('StorageClient:getObject() is deprecated')

    getObjectIds : ->
      throw new Error('StorageClient:getObjectIds() is deprecated')

    getObjectMetadata : (id) ->
      throw new Error('StorageClient:getObjectMetadata() is deprecated')

    deleteObject : (id) ->
      throw new Error('StorageClient:deleteObject() is deprecated')

    uploadObject : (storageRequest, objectSearchPair) ->
      console.trace()
      console.log('StorageClient:uploadObject()')
      { objectIdPair, objectKey } = {}
      storageResponse = {}

      Promise.resolve()
      .then ->
        storageRequest.validate()
      .then =>
        @objectListingApi.getTypeIdForTypeName(storageRequest.type)
      .then (typeId) =>
        storageResponse.typeId = typeId
        createObjectRequest = new CreateObjectRequest({
          type: typeId
          requiredCryptoMats: [ 'IV', 'CONTENTS' ]
        })
        if storageRequest.parent?
          console.log('StorageClient:uploadObject() - storageRequest.parent')
          console.log(storageRequest.parent)
          createObjectRequest.parentObjectId = storageRequest.parent
        @objectApi.createObject(createObjectRequest)
      .then (versionedObjectKey) =>
        objectKey = versionedObjectKey
        objectIdPair = {
          objectId       : objectKey.objectId
          parentObjectId : if storageRequest.parent then storageRequest.parent.objectId else objectKey.objectId
        }
        storageResponse.objectKey = objectKey
        storageResponse.objectIdPair = objectIdPair
        @cryptoServiceLoader.getObjectCryptoServiceV2(
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
        storageResponse.objectSearchPair = objectSearchPair
        return storageResponse

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
