define 'kryptnostic.crypto-service-loader', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.cypher',
  'kryptnostic.caching-service'
  'kryptnostic.rsa-crypto-service',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.directory-api',
  'kryptnostic.key-storage-api',
  'kryptnostic.crypto-service-marshaller',
  'kryptnostic.credential-loader',
  'kryptnostic.object-utils'
], (require) ->
  'use strict'

  Promise                 = require 'bluebird'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  AesCryptoService        = require 'kryptnostic.aes-crypto-service'
  Cache                   = require 'kryptnostic.caching-service'
  Cypher                  = require 'kryptnostic.cypher'
  DirectoryApi            = require 'kryptnostic.directory-api'
  KeyStorageApi           = require 'kryptnostic.key-storage-api'
  Logger                  = require 'kryptnostic.logger'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  CredentialLoader        = require 'kryptnostic.credential-loader'
  ObjectUtils             = require 'kryptnostic.object-utils'

  INT_SIZE     = 4
  EMPTY_BUFFER = ''

  log = Logger.get('CryptoServiceLoader')

  DEFAULT_OPTS = { expectMiss: false }

  #
  # Loads cryptoservices which can be used for object decryption.
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: ->
      @directoryApi  = new DirectoryApi()
      @keyStorageApi = new KeyStorageApi()
      @marshaller    = new CryptoServiceMarshaller()
      @cache         = {}

    @initializeMasterAesCryptoService: ->

      Promise.resolve(
        KeyStorageApi.getMasterAesCryptoService()
      )
      .then (masterAesCryptoService) =>

        if not masterAesCryptoService

          masterAesCryptoService = new AesCryptoService(Cypher.AES_CTR_128)
          cryptoServiceMarshaller = new CryptoServiceMarshaller()
          marshalledCryptoService = cryptoServiceMarshaller.marshall(masterAesCryptoService)

          credentialLoader = new CredentialLoader()
          rsaCryptoService = new RsaCryptoService(credentialLoader.getCredentials().keypair)
          encryptedMasterAesCryptoService = rsaCryptoService.encrypt(marshalledCryptoService)

          return KeyStorageApi.setMasterAesCryptoService(encryptedMasterAesCryptoService)

    getRsaCryptoService: ->
      credentialLoader = new CredentialLoader()
      return new RsaCryptoService(credentialLoader.getCredentials().keypair)

    getMasterAesCryptoService: ->

      if @cache[Cache.MASTER_AES_CRYPTO_SERVICE_ID]
        return Promise.resolve(@cache[Cache.MASTER_AES_CRYPTO_SERVICE_ID])

      Promise.resolve(
        KeyStorageApi.getMasterAesCryptoService()
      )
      .then (serializedCryptoService) =>
        decryptedCryptoService = @getRsaCryptoService().decrypt(serializedCryptoService)
        masterAesCryptoService = @marshaller.unmarshall(decryptedCryptoService)
        @cache[Cache.MASTER_AES_CRYPTO_SERVICE_ID] = masterAesCryptoService
        return masterAesCryptoService

    getObjectCryptoService: (id, options) ->
      options        = _.defaults({}, options, DEFAULT_OPTS)
      { expectMiss } = options

      id = ObjectUtils.childIdToParent(id)

      # Check cache for crypto service
      if @cache[id]
        return Promise.resolve(@cache[id])
      # if cache miss get from network, and update cache
      Promise.props({
        serializedCryptoService : @directoryApi.getObjectCryptoService(id)
      })
      .then ({ serializedCryptoService }) =>
        cryptoService = {}
        if !serializedCryptoService && expectMiss
          log.info('no cryptoService exists for this object. creating one on-the-fly', { id })
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoService( id, cryptoService )
        else if !serializedCryptoService && !expectMiss
          throw new Error 'no cryptoservice exists for this object, but a miss was not expected'
        else
          decodedCryptoService = atob(serializedCryptoService)
          deflatedCryptoService = @getRsaCryptoService().decrypt(decodedCryptoService)
          cryptoService = @marshaller.unmarshall(deflatedCryptoService)
        @cache[id] = cryptoService
        return cryptoService

    getObjectCryptoServiceV2: (versionedObjectKey, options) ->
      console.log('CryptoServiceLoader:getObjectCryptoServiceV2()')
      options        = _.defaults({}, options, DEFAULT_OPTS)
      { expectMiss } = options

      objectId = versionedObjectKey.objectId

      if @cache[objectId]
        return Promise.resolve(@cache[objectId])

      Promise.props({
        masterAesCryptoService       : @getMasterAesCryptoService()
        cryptoServiceBlockCiphertext : @keyStorageApi.getAesEncryptedObjectCryptoService(versionedObjectKey)
      })
      .then ({ masterAesCryptoService, cryptoServiceBlockCiphertext }) =>
        objectCryptoService = {}
        if !cryptoServiceBlockCiphertext && expectMiss
          log.info('no cryptoService exists for this object. creating one on-the-fly', { objectId })
          objectCryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoServiceV2(versionedObjectKey, objectCryptoService, masterAesCryptoService)
        else if !cryptoServiceBlockCiphertext && !expectMiss
          console.log('CryptoServiceLoader:getObjectCryptoServiceV2()')
          console.log(objectId)
          console.error('no cryptoservice exists for this object, but a miss was not expected')
          return null
        else
          decryptedCryptoService = masterAesCryptoService.decrypt(cryptoServiceBlockCiphertext)
          objectCryptoService = @marshaller.unmarshall(decryptedCryptoService, masterAesCryptoService)
          @cache[objectId] = objectCryptoService
        return objectCryptoService

    setObjectCryptoService: (id, cryptoService) ->
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')

      marshalled             = @marshaller.marshall(cryptoService)
      encryptedCryptoService = @getRsaCryptoService().encrypt(marshalled)

      return @directoryApi.setObjectCryptoService(id, encryptedCryptoService)

    setObjectCryptoServiceV2: (versionedObjectKey, objectCryptoService, masterAesCryptoService) ->
      console.log('CryptoServiceLoader:setObjectCryptoServiceV2()')
      unless objectCryptoService.constructor.name is 'AesCryptoService'
        throw new Error('support is only implemented for AesCryptoService')

      marshalledCryptoService = @marshaller.marshall(objectCryptoService)
      encryptedCryptoService  = masterAesCryptoService.encrypt(marshalledCryptoService)

      Promise.resolve(
        @keyStorageApi.setAesEncryptedObjectCryptoService(versionedObjectKey, encryptedCryptoService)
      )
      .then =>
        @cache[versionedObjectKey.objectId] = objectCryptoService
        return

  return CryptoServiceLoader
