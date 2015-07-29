define 'kryptnostic.crypto-service-loader', [
  'require',
  'jquery',
  'kryptnostic.logger'
  'kryptnostic.cypher',
  'kryptnostic.rsa-crypto-service',
  'kryptnostic.aes-crypto-service'
  'kryptnostic.directory-api'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  jquery                  = require 'jquery'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  AesCryptoService        = require 'kryptnostic.aes-crypto-service'
  Cypher                  = require 'kryptnostic.cypher'
  DirectoryApi            = require 'kryptnostic.directory-api'
  Logger                  = require 'kryptnostic.logger'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  CredentialLoader        = require 'kryptnostic.credential-loader'

  INT_SIZE     = 4
  EMPTY_BUFFER = ''

  logger = Logger.get('CryptoServiceLoader')

  DEFAULT_OPTS = { expectMiss: false }

  #
  # Loads cryptoservices which can be used for object decryption.
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: ->
      @directoryApi     = new DirectoryApi()
      @marshaller       = new CryptoServiceMarshaller()

    getRsaCryptoService: ->
      { keypair } = CredentialLoader.getCredentials()
      return new RsaCryptoService(keypair)

    getObjectCryptoService: (id, options) ->
      options          = _.defaults({}, options, DEFAULT_OPTS)
      { expectMiss }   = options
      rsaCryptoService = @getRsaCryptoService()

      return  @directoryApi.getObjectCryptoService(id)
      .then (serializedCryptoService) =>
        if !serializedCryptoService && expectMiss
          logger.info('no cryptoService exists for this object. creating one on-the-fly', { id })
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoService( id, cryptoService )
          return cryptoService
        else if !serializedCryptoService && !expectMiss
          throw new Error 'no cryptoservice exists for this object, but a miss was not expected'
        else
          cryptoService = @marshaller.unmarshall(serializedCryptoService, rsaCryptoService)
          return cryptoService

    setObjectCryptoService: (id, cryptoService) ->
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')

      marshalled             = @marshaller.marshall(cryptoService)
      rsaCryptoService       = @getRsaCryptoService()
      encryptedCryptoService = rsaCryptoService.encrypt(marshalled)

      return @directoryApi.setObjectCryptoService(id, encryptedCryptoService)

  return CryptoServiceLoader
