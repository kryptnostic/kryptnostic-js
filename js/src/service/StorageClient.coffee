# coffeelint: disable=cyclomatic_complexity

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
  'kryptnostic.indexing.object-indexing-service'
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
  ObjectIndexingService = require 'kryptnostic.indexing.object-indexing-service'
  CredentialLoader      = require 'kryptnostic.credential-loader'

  # utils
  Logger      = require 'kryptnostic.logger'
  Validators  = require 'kryptnostic.validators'

  {
    validateUuid,
    validateUuids,
    validateVersionedObjectKey,
    validateVersionedObjectKeys
  } = Validators

  logger = Logger.get('StorageClient')

  class StorageClient

    constructor : ->
      logger.info 'storage client created'
      @objectApi             = new ObjectApi()
      @objectListingApi      = new ObjectListingApi()
      @cryptoServiceLoader   = new CryptoServiceLoader()
      @objectIndexingService = new ObjectIndexingService()
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
          cryptoServicePromise = @cryptoServiceLoader.getObjectCryptoService(parentObjectKey)
        else
          cryptoServicePromise = @cryptoServiceLoader.getObjectCryptoService(objectKey)

        Promise.props({
          blockCiphertext : @objectApi.getObjectAsBlockCiphertext(objectKey),
          cryptoService   : cryptoServicePromise
        })
        .then ({ blockCiphertext, cryptoService }) ->
          if blockCiphertext and cryptoService
            decrypted = cryptoService.decrypt(blockCiphertext)
            return decrypted
          else
            return null

    getObjects: (objectKeys) ->

      promises = []
      _.forEach(objectKeys, (objectKey) =>

        if not validateVersionedObjectKey(objectKey)
          logger.error('invalid versioned object key')
          return

        promise = Promise.join(
          @cryptoServiceLoader.getObjectCryptoService(objectKey),
          @objectApi.getObjectAsBlockCiphertext(objectKey)
        )
        .then (objectMaterial) ->
          return {
            objectKey       : objectKey,
            cryptoService   : objectMaterial[0],
            blockCiphertext : objectMaterial[1]
          }
        .catch (error) ->
          return {
            objectKey       : objectKey,
            cryptoService   : null,
            blockCiphertext : null
          }

        promises.push(promise)
      )

      Promise.all(promises)
      .then (resolvedPromises) ->

        result = {}
        _.forEach(resolvedPromises, (resolved) ->
          objectKey = resolved.objectKey
          cryptoService = resolved.cryptoService
          blockCiphertext = resolved.blockCiphertext
          if blockCiphertext and cryptoService
            decrypted = cryptoService.decrypt(blockCiphertext)
            result[objectKey.objectId] = decrypted
        )
        return result
      .catch (error) ->
        logger.error('Failed to get objects')

    #
    # returns Array<Object> where each element contains the objectKey and the decrypted object data
    #   [{
    #     objectKey,
    #     data
    #   }]
    #
    getChildrenObjects: (objectKeys, parentObjectKey) ->

      if not validateVersionedObjectKeys(objectKeys)
        return Promise.reject(new Error('objectKeys is an invalid array of VersionedObjectKeys'))

      if not validateVersionedObjectKey(parentObjectKey)
        return Promise.reject(new Error('parentObjectKey is an invalid VersionedObjectKey'))

      if _.isEmpty(objectKeys)
        return Promise.resolve([])

      Promise.resolve(
        @cryptoServiceLoader.getObjectCryptoService(parentObjectKey)
      )
      .then (parentObjectCryptoService) =>

        if not parentObjectCryptoService
          return Promise.reject(new Error('failed to get parent ObjectCryptoService'))

        # prefill the response with the objectKeys
        response = []
        _.forEach(objectKeys, (objectKey) ->
          response.push({
            objectKey
          })
        )

        objectPromises = []
        _.forEach(objectKeys, (objectKey, index) =>
          promise = Promise.resolve(
            @objectApi.getObjectAsBlockCiphertext(objectKey)
          )
          .then (blockCipherText) ->
            if blockCipherText
              decryptedObject = parentObjectCryptoService.decrypt(blockCipherText)
              response[index].data = decryptedObject
          .catch (error) ->
            return
          objectPromises.push(promise)
        )

        Promise.all(objectPromises)
        .then ->
          return response

      .catch (e) ->
        logger.error(e)
        return Promise.reject(new Error('failed to get children objects'))

    getChildObjectsByTypeAndLoadLevel: (objectIds, parentObjectId, typeLoadLevels, loadDepth) ->

      if not validateUuids(objectIds) or not validateUuid(parentObjectId)
        return Promise.resolve(null)

      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(parentObjectId)
      )
      .then (parentObjectKey) =>
        Promise.props({
          objectCryptoService : @cryptoServiceLoader.getObjectCryptoService(parentObjectKey)
          objectMetadataTrees : @objectApi.getObjectsByTypeAndLoadLevel(
            objectIds,
            typeLoadLevels,
            loadDepth
          )
        })
        .then ({ objectMetadataTrees, objectCryptoService }) ->
          childObjects = {}
          _.forEach(objectIds, (objectId, index) ->
            result = objectMetadataTrees[objectId]
            blockCiphertext = objectMetadataTrees[objectId].data
            if blockCiphertext and objectCryptoService
              try
                decrypted = objectCryptoService.decrypt(blockCiphertext)
                result.data = decrypted
              catch e
                result.data = ''
            childObjects[objectId] = result
          )
          return childObjects

    getObjectTreeByTypeAndLoadLevelPaged: (objectTreePagedRequest) ->

      Promise.props({
        objectCryptoService: @cryptoServiceLoader.getObjectCryptoService(objectTreePagedRequest.objectKey)
        objectTreePagedResponse: @objectApi.getObjectTreeByTypeAndLoadLevelPaged(objectTreePagedRequest)
      })
      .then ({ objectCryptoService, objectTreePagedResponse }) ->

        objectCryptoService.decryptObjectMetadataTree(objectTreePagedResponse.objectMetadataTree)
        return objectTreePagedResponse

    storeObject: (storageRequest) ->

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
          })

          if parentObjectKey?
            createObjectRequest.parentObjectId = parentObjectKey

          Promise.resolve(
            @objectApi.createObject(createObjectRequest)
          )
          .then (objectKeyForNewlyCreatedObject) =>
            cryptoServicePromise = null
            if parentObjectKey?
              cryptoServicePromise = @cryptoServiceLoader.getObjectCryptoService(parentObjectKey)
            else
              cryptoServicePromise = @cryptoServiceLoader.createObjectCryptoService(objectKeyForNewlyCreatedObject)
            Promise.resolve(
              cryptoServicePromise
            )
            .then (cryptoService) =>
              # ToDo: for now, we encrypt the entire object, but we'll need to support encrypting an object in chunks
              @encrypt(objectKeyForNewlyCreatedObject.objectId, storageRequest.body, cryptoService)
            .then (encrypted) =>
              blockCiphertext = encrypted.body.data[0].block
              @objectApi.setObjectFromBlockCiphertext(objectKeyForNewlyCreatedObject, blockCiphertext)
            .then =>
              if storageRequest.isSearchable
                @objectIndexingService.enqueueIndexTask(
                  storageRequest.body,
                  objectKeyForNewlyCreatedObject,
                  parentObjectKey
                )
            .then ->
              storageResponse.objectKey = objectKeyForNewlyCreatedObject
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

    updateObject: (objectId, content) ->

      if not validateUuid(objectId)
        return Promise.resolve(null)

      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(objectId)
      )
      .then (latestObjectKey) =>
        Promise.resolve(
          @cryptoServiceLoader.getObjectCryptoService(versionedObjectKey)
        )
        .then (objectCryptoService) =>
          # ToDo: for now, we encrypt the entire object, but we'll need to support encrypting an object in chunks
          @encrypt(latestObjectKey.objectId, content, objectCryptoService)
        .then (encrypted) =>
          blockCiphertext = encrypted.body.data[0].block
          @objectApi.setObjectFromBlockCiphertext(versionedObjectKey, blockCiphertext)

          # ToDo: index updated object for it to be searchable
          @objectIndexingService.enqueueIndexTask(
            content,
            objectKeyForNewlyCreatedObject,
            parentObjectKey
          )
          return

    updateObjectType: (objectId, type) ->
      if not validateUuid(objectId)
        logger.error('invalid object UUID')
        return Promise.reject()

      Promise.resolve(
        @objectApi.updateType(objectId, type)
      )

    deleteObject: (objectId) ->
      if not validateUuid(objectId)
        return Promise.resolve()

      return Promise.resolve(
        @objectApi.deleteObject(objectId)
      )

  return StorageClient
