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
  'kryptnostic.crypto-material'
], (require) ->
  'use strict'

  # libraries
  Promise = require 'bluebird'

  # kryptnostic
  CryptoMaterial        = require 'kryptnostic.crypto-material'
  CreateObjectRequest   = require 'kryptnostic.create-object-request'
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  ObjectApi             = require 'kryptnostic.object-api'
  ObjectListingApi      = require 'kryptnostic.object-listing-api'
  SearchIndexingService = require 'kryptnostic.search-indexing-service'
  CredentialLoader      = require 'kryptnostic.credential-loader'

  # utils
  Logger      = require 'kryptnostic.logger'
  Validators  = require 'kryptnostic.validators'

  { validateUuid, validateUuids } = Validators

  logger = Logger.get('StorageClient')

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  #
  class StorageClient

    constructor : ->
      logger.info 'storage client created'
      @objectApi             = new ObjectApi()
      @objectListingApi      = new ObjectListingApi()
      @cryptoServiceLoader   = new CryptoServiceLoader()
      @searchIndexingService = new SearchIndexingService()
      @credentialLoader      = new CredentialLoader()

    getObject: (objectId, parentObjectId) ->

      if not validateUuid(objectId)
        return Promise.resolve(null)

      parentObjectKeyPromise = null
      if parentObjectId?
        parentObjectKeyPromise = @objectApi.getLatestVersionedObjectKey(parentObjectId)

      Promise.props({
        objectKey       : @objectApi.getLatestVersionedObjectKey(objectId)
        parentObjectKey : parentObjectKeyPromise
      })
      .then ({ objectKey, parentObjectKey }) =>

        cryptoServicePromise = null
        if parentObjectKey?
          cryptoServicePromise = @cryptoServiceLoader.getObjectCryptoServiceV2(parentObjectKey)
        else
          cryptoServicePromise = @cryptoServiceLoader.getObjectCryptoServiceV2(objectKey)

        Promise.props({
          blockCiphertext : @objectApi.getObjectAsBlockCiphertext(objectKey),
          cryptoService   : cryptoServicePromise
        })
        .then ({ blockCiphertext, cryptoService }) ->
          if blockCiphertext? and cryptoService?
            decrypted = cryptoService.decrypt(blockCiphertext)
            return decrypted
          else
            return null

    getObjects: (objectIds) ->

      objectKeyPromises = []
      _.forEach(objectIds, (objectId) =>
        objectKeyPromises.push(
          @objectApi.getLatestVersionedObjectKey(objectId)
        )
      )

      Promise.all(objectKeyPromises)
      .then (objectKeys) =>

        promises = []
        _.forEach(objectKeys, (objectKey) =>
          promise = Promise.props({
            objectKey       : objectKey
            cryptoService   : @cryptoServiceLoader.getObjectCryptoServiceV2(objectKey)
            blockCiphertext : @objectApi.getObjectAsBlockCiphertext(objectKey)
          })
          promises.push(promise)
        )

        Promise.all(promises)
        .then (resolvedPromises) =>

          result = {}
          _.forEach(resolvedPromises, (resolved) =>
            objectKey = resolved.objectKey
            cryptoService = resolved.cryptoService
            blockCiphertext = resolved.blockCiphertext
            if blockCiphertext? and cryptoService?
              decrypted = cryptoService.decrypt(blockCiphertext)
              result[objectKey.objectId] = decrypted
          )
          return result

    getChildObjects: (objectIds, parentObjectId) ->

      if not validateUuids(objectIds) or not validateUuid(parentObjectId)
        return Promise.resolve(null)

      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(parentObjectId)
      )
      .then (parentObjectKey) =>

        Promise.props({
          cryptoService          : @cryptoServiceLoader.getObjectCryptoServiceV2(parentObjectKey)
          objectBlockCiphertexts : @objectApi.getObjects(objectIds)
        })
        .then ({ cryptoService, objectBlockCiphertexts }) =>

          childObjects = {}
          _.forEach(objectIds, (objectId, index) =>
            blockCiphertext = objectBlockCiphertexts[objectId]
            if blockCiphertext? and cryptoService?
              decrypted = cryptoService.decrypt(blockCiphertext)
              childObjects[objectId] = decrypted
          )
          return childObjects

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
        parentObjectKeyPromise = @objectApi.getLatestVersionedObjectKey(storageRequest.parentId)

      Promise.join(
        typeIdPromise,
        parentObjectKeyPromise,
        (typeId, parentObjectKey) =>

          createObjectRequest = new CreateObjectRequest({
            type: typeId,
            requiredCryptoMats: CryptoMaterial.DEFAULT_REQUIRED_CRYPTO_MATERIAL
          })

          if parentObjectKey?
            createObjectRequest.parentObjectId = parentObjectKey

          Promise.resolve(
            @objectApi.createObject(createObjectRequest)
          )
          .then (objectKeyForNewlyCreatedObject) =>
            parentObjectKey = if parentObjectKey? then parentObjectKey else objectKeyForNewlyCreatedObject
            Promise.resolve(
              @cryptoServiceLoader.getObjectCryptoServiceV2(
                parentObjectKey,
                { expectMiss : true }
              )
            )
            .then (cryptoService) =>
              @encrypt(objectKeyForNewlyCreatedObject.objectId, storageRequest.body, cryptoService)
            .then (encrypted) =>
              # for now, we'll encrypt the entire object, but we'll need to support encrypting an object in chunks
              # @submitObjectBlocks(encrypted)
              blockCiphertext = encrypted.body.data[0].block
              @objectApi.setObjectFromBlockCiphertext(objectKeyForNewlyCreatedObject, blockCiphertext)
            .then =>
              @searchIndexingService.submit(
                storageRequest,
                objectKeyForNewlyCreatedObject,
                parentObjectKey,
                objectSearchPair
              )
            .then (objectSearchPair) ->
              storageResponse.objectKey = objectKeyForNewlyCreatedObject
              storageResponse.objectSearchPair = objectSearchPair
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
