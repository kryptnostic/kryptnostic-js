# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.crypto-service-loader', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.cypher',
  'kryptnostic.caching-service'
  'kryptnostic.rsa-crypto-service',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.key-storage-api',
  'kryptnostic.crypto-service-marshaller',
  'kryptnostic.credential-loader'
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

  INT_SIZE     = 4
  EMPTY_BUFFER = ''
  masterAesCryptoService = null
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
      .then (masterAesCryptoService_) ->

        if not masterAesCryptoService_

          masterAesCryptoService_ = new AesCryptoService(Cypher.AES_CTR_128)
          cryptoServiceMarshaller = new CryptoServiceMarshaller()
          marshalledCryptoService = cryptoServiceMarshaller.marshall(masterAesCryptoService_)

          credentialLoader = new CredentialLoader()
          rsaCryptoService = new RsaCryptoService(credentialLoader.getCredentials().keypair)
          encryptedMasterAesCryptoService = rsaCryptoService.encrypt(marshalledCryptoService)

          return KeyStorageApi.setMasterAesCryptoService(encryptedMasterAesCryptoService)

    getRsaCryptoService: ->
      credentialLoader = new CredentialLoader()
      rsaCryptoService = new RsaCryptoService(credentialLoader.getCredentials().keypair)
      return rsaCryptoService

    getMasterAesCryptoService: ->

      if masterAesCryptoService
        return Promise.resolve(masterAesCryptoService)

      Promise.resolve(
        KeyStorageApi.getMasterAesCryptoService()
      )
      .then (serializedCryptoService) =>
        if not masterAesCryptoService
          decryptedCryptoService = @getRsaCryptoService().decrypt(serializedCryptoService)
          masterAesCryptoService = @marshaller.unmarshall(decryptedCryptoService)
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
          objectCryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoServiceV2(versionedObjectKey, objectCryptoService, masterAesCryptoService)
        else if !cryptoServiceBlockCiphertext && !expectMiss
          log.error('no cryptoservice exists for this object, but a miss was not expected')
          return null
        else
          decryptedCryptoService = masterAesCryptoService.decrypt(cryptoServiceBlockCiphertext)
          objectCryptoService = @marshaller.unmarshall(decryptedCryptoService, masterAesCryptoService)
          @cache[objectId] = objectCryptoService
        return objectCryptoService

    setObjectCryptoServiceV2: (versionedObjectKey, objectCryptoService, masterAesCryptoService) ->
      unless objectCryptoService.constructor.name is 'AesCryptoService'
        throw new Error('support is only implemented for AesCryptoService')

      marshalledCryptoService = @marshaller.marshall(objectCryptoService)
      encryptedCryptoService  = masterAesCryptoService.encrypt(marshalledCryptoService)

      Promise.resolve(
        KeyStorageApi.setAesEncryptedObjectCryptoService(versionedObjectKey, encryptedCryptoService)
      )
      .then =>
        @cache[versionedObjectKey.objectId] = objectCryptoService
        return

  return CryptoServiceLoader
