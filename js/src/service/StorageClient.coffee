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

        objectCryptoServicePromise = null
        if parentObjectKey?
          objectCryptoServicePromise = @cryptoServiceLoader.getObjectCryptoService(parentObjectKey)
        else
          objectCryptoServicePromise = @cryptoServiceLoader.getObjectCryptoService(objectKey)

        Promise.props({
          blockCipherText: @objectApi.getObjectAsBlockCiphertext(objectKey),
          objectCryptoService: objectCryptoServicePromise
        })
        .then ({ blockCipherText, objectCryptoService }) ->
          if blockCipherText and objectCryptoService
            decrypted = objectCryptoService.decrypt(blockCipherText)
            return decrypted
          else
            return null

    #
    # returns Array<Object> where each element contains the objectKey and the decrypted object data
    #   [{
    #     objectKey,
    #     data
    #   }]
    #
    getObjects: (objectKeys) ->

      if not validateVersionedObjectKeys(objectKeys)
        return Promise.reject(new Error('objectKeys is an invalid array of VersionedObjectKeys'))

      if _.isEmpty(objectKeys)
        return Promise.resolve([])

      # prefill the response with the objectKeys
      response = []
      _.forEach(objectKeys, (objectKey) ->
        response.push({
          objectKey
        })
      )

      objectPromises = []
      _.forEach(objectKeys, (objectKey, index) =>

        promise = Promise.props({
          objectCryptoService: @cryptoServiceLoader.getObjectCryptoService(objectKey),
          blockCipherText: @objectApi.getObjectAsBlockCiphertext(objectKey)
        })
        .then ({ objectCryptoService, blockCipherText }) ->
          if blockCipherText and objectCryptoService
            decryptedObject = objectCryptoService.decrypt(blockCipherText)
            response[index].data = decryptedObject
        .catch (e) ->
          return

        objectPromises.push(promise)
      )

      Promise.all(objectPromises)
      .then ->
        return response
      .catch (e) ->
        logger.error(e)
        return Promise.reject(new Error('failed to get objects'))

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
          .catch (e) ->
            return
          objectPromises.push(promise)
        )

        Promise.all(objectPromises)
        .then ->
          return response

      .catch (e) ->
        logger.error(e)
        return Promise.reject(new Error('failed to get children objects'))

    getObjectTreeByTypeAndLoadLevel: (objectTreeRequest) ->

      Promise.props({
        objectCryptoService: @cryptoServiceLoader.getObjectCryptoService(objectTreeRequest.rootObjectKey)
        objectTreeResponse: @objectApi.getObjectTreeByTypeAndLoadLevel(objectTreeRequest)
      })
      .then ({ objectCryptoService, objectTreeResponse }) ->

        if not _.isObject(objectCryptoService) or _.isEmpty(objectCryptoService) or
            not _.isObject(objectTreeResponse) or _.isEmpty(objectTreeResponse)
          return null

        objectCryptoService.decryptObjectMetadataTree(objectTreeResponse.objectMetadataTree)
        return objectTreeResponse

    getObjectTreeByTypeAndLoadLevelPaged: (objectTreePagedRequest) ->

      Promise.props({
        objectCryptoService: @cryptoServiceLoader.getObjectCryptoService(objectTreePagedRequest.rootObjectKey)
        objectTreePagedResponse: @objectApi.getObjectTreeByTypeAndLoadLevelPaged(objectTreePagedRequest)
      })
      .then ({ objectCryptoService, objectTreePagedResponse }) ->

        if not _.isObject(objectCryptoService) or _.isEmpty(objectCryptoService) or
            not _.isObject(objectTreePagedResponse) or _.isEmpty(objectTreePagedResponse)
          return null

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
            objCryptoServicePromise = null
            if parentObjectKey?
              objCryptoServicePromise = @cryptoServiceLoader.getObjectCryptoService(parentObjectKey)
            else
              objCryptoServicePromise = @cryptoServiceLoader.createObjectCryptoService(objectKeyForNewlyCreatedObject)
            Promise.resolve(
              objCryptoServicePromise
            )
            .then (objectCryptoService) =>
              # ToDo: for now, we encrypt the entire object, but we'll need to support encrypting an object in chunks
              @encrypt(objectKeyForNewlyCreatedObject.objectId, storageRequest.body, objectCryptoService)
            .then (encrypted) =>
              blockCipherText = encrypted.body.data[0].block
              @objectApi.setObjectFromBlockCiphertext(objectKeyForNewlyCreatedObject, blockCipherText)
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

    encrypt : (objectId, body, objectCryptoService) ->
      kryptnosticObject = KryptnosticObject.createFromDecrypted({
        id: objectId,
        body: body
      })
      return kryptnosticObject.encrypt(objectCryptoService)

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
          blockCipherText = encrypted.body.data[0].block
          @objectApi.setObjectFromBlockCiphertext(versionedObjectKey, blockCipherText)

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
