# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.crypto-service-loader', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.caching-service'
  'kryptnostic.cypher',
  'kryptnostic.caching-service'
  'kryptnostic.rsa-crypto-service',
  'kryptnostic.aes-crypto-service',
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
      @marshaller    = new CryptoServiceMarshaller()
      @cache         = {}

    @initializeMasterAesCryptoService: ->

      Promise.resolve(
        KeyStorageApi.getMasterAesCryptoService()
      )
      .then (masterAesCryptoService) =>
        if not masterAesCryptoService
          Promise.resolve()
          .then =>
            AesCryptoService.get(Cypher.AES_CTR_128)
          .then (aesCryptoService) =>
            cryptoServiceMarshaller = new CryptoServiceMarshaller()
            cryptoServiceMarshaller.marshall(aesCryptoService)
          .then (marshalledCryptoService) =>
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
      .then (encryptedMarshalledCryptoService) =>
        marshalledCryptoService = @getRsaCryptoService().decrypt(encryptedMarshalledCryptoService)
        return @marshaller.unmarshall(marshalledCryptoService)
      .then (masterAesCryptoService) =>
        @cache[Cache.MASTER_AES_CRYPTO_SERVICE_ID] = masterAesCryptoService
        return masterAesCryptoService

    getObjectCryptoServiceV2: (versionedObjectKey, options) ->
      options        = _.defaults({}, options, DEFAULT_OPTS)
      { expectMiss } = options

      objectId = versionedObjectKey.objectId

      if @cache[objectId]
        return Promise.resolve(@cache[objectId])

      Promise.props({
        masterAesCryptoService       : @getMasterAesCryptoService()
        cryptoServiceBlockCiphertext : KeyStorageApi.getAesEncryptedObjectCryptoService(versionedObjectKey)
      })
      .then ({ masterAesCryptoService, cryptoServiceBlockCiphertext }) =>
        objectCryptoService = {}
        if !cryptoServiceBlockCiphertext && expectMiss
          log.info('no cryptoService exists for this object. creating one on-the-fly', { objectId })
          Promise.resolve(
            AesCryptoService.get(Cypher.AES_CTR_128)
          )
          .then (aesCryptoService) =>
            @setObjectCryptoServiceV2(versionedObjectKey, aesCryptoService, masterAesCryptoService)
            return Promise.resolve(aesCryptoService)
        else if !cryptoServiceBlockCiphertext && !expectMiss
          log.error('no cryptoservice exists for this object, but a miss was not expected')
          return Promise.resolve(null)
        else
          Promise.resolve()
          .then =>
            masterAesCryptoService.decrypt(cryptoServiceBlockCiphertext)
          .then (decryptedCryptoService) =>
            @marshaller.unmarshall(decryptedCryptoService, masterAesCryptoService)
          .then (unmarshalledCryptoService) =>
            @cache[objectId] = unmarshalledCryptoService
            return unmarshalledCryptoService

    setObjectCryptoServiceV2: (versionedObjectKey, objectCryptoService, masterAesCryptoService) ->
      unless objectCryptoService.constructor.name is 'AesCryptoService'
        throw new Error('support is only implemented for AesCryptoService')

      Promise.resolve()
      .then =>
        @marshaller.marshall(objectCryptoService)
      .then (marshalledCryptoService) =>
        masterAesCryptoService.encrypt(marshalledCryptoService)
      .then (encryptedCryptoService) =>
        KeyStorageApi.setAesEncryptedObjectCryptoService(versionedObjectKey, encryptedCryptoService)
      .then =>
        @cache[versionedObjectKey.objectId] = objectCryptoService
        return

  return CryptoServiceLoader
