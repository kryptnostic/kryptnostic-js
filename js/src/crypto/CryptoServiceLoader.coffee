define 'kryptnostic.crypto-service-loader', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.cypher',
  'kryptnostic.rsa-crypto-service',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.directory-api',
  'kryptnostic.crypto-service-marshaller',
  'kryptnostic.credential-loader',
  'kryptnostic.object-utils'
], (require) ->
  'use strict'

  Promise                 = require 'bluebird'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  AesCryptoService        = require 'kryptnostic.aes-crypto-service'
  Cypher                  = require 'kryptnostic.cypher'
  DirectoryApi            = require 'kryptnostic.directory-api'
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
      @directoryApi     = new DirectoryApi()
      @marshaller       = new CryptoServiceMarshaller()
      @credentialLoader = new CredentialLoader()
      @cache            = {}

    getRsaCryptoService: ->
      { keypair } = @credentialLoader.getCredentials()
      return new RsaCryptoService(keypair)

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
          rsaCryptoService = @getRsaCryptoService()
          cryptoService = @marshaller.unmarshall(serializedCryptoService, rsaCryptoService)
        @cache[id] = cryptoService
        return cryptoService

    getObjectCryptoServiceV2: (id, options) ->
      console.log('CryptoServiceLoader:getObjectCryptoServiceV2()')
      options        = _.defaults({}, options, DEFAULT_OPTS)
      { expectMiss } = options

      id = ObjectUtils.childIdToParent(id)

      # Check cache for crypto service
      if @cache[id]
        return Promise.resolve(@cache[id])
      # if cache miss get from network, and update cache
      Promise.props({
        serializedCryptoService : @directoryApi.getObjectCryptoServiceV2(id)
      })
      .then ({ serializedCryptoService }) =>
        cryptoService = {}
        if !serializedCryptoService && expectMiss
          log.info('no cryptoService exists for this object. creating one on-the-fly', { id })
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoServiceV2( id, cryptoService )
        else if !serializedCryptoService && !expectMiss
          console.log('CryptoServiceLoader:getObjectCryptoServiceV2()')
          console.log(id)
          throw new Error 'no cryptoservice exists for this object, but a miss was not expected'
        else
          rsaCryptoService = @getRsaCryptoService()
          cryptoService = @marshaller.unmarshall(serializedCryptoService, rsaCryptoService)
        @cache[id] = cryptoService
        return cryptoService

    setObjectCryptoService: (id, cryptoService) ->
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')

      marshalled             = @marshaller.marshall(cryptoService)
      rsaCryptoService       = @getRsaCryptoService()
      encryptedCryptoService = rsaCryptoService.encrypt(marshalled)

      return @directoryApi.setObjectCryptoService(id, encryptedCryptoService)

    setObjectCryptoServiceV2: (id, cryptoService) ->
      console.log('CryptoServiceLoader:setObjectCryptoServiceV2()')
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')

      marshalled             = @marshaller.marshall(cryptoService)
      rsaCryptoService       = @getRsaCryptoService()
      encryptedCryptoService = rsaCryptoService.encrypt(marshalled)

      return @directoryApi.setObjectCryptoServiceV2(id, encryptedCryptoService)

  cryptoServiceLoader = new CryptoServiceLoader()

  get = ->
    return cryptoServiceLoader

  return {
    get
  }
