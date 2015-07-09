define 'soteria.crypto-service-loader', [
  'require',
  'jquery',
  'soteria.logger'
  'soteria.cypher',
  'soteria.rsa-crypto-service',
  'soteria.aes-crypto-service'
  'soteria.directory-api'
  'soteria.crypto-service-marshaller'
  'soteria.credential-store'
], (require) ->
  'use strict'

  jquery                  = require 'jquery'
  RsaCryptoService        = require 'soteria.rsa-crypto-service'
  AesCryptoService        = require 'soteria.aes-crypto-service'
  Cypher                  = require 'soteria.cypher'
  DirectoryApi            = require 'soteria.directory-api'
  Logger                  = require 'soteria.logger'
  CryptoServiceMarshaller = require 'soteria.crypto-service-marshaller'
  CredentialStore   = require 'soteria.credential-store'

  INT_SIZE     = 4
  EMPTY_BUFFER = ''

  logger = Logger.get('CryptoServiceLoader')

  DEFAULT_OPTS = {expectMiss: false}

  #
  # Loads cryptoservices which can be used for object decryption.
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: ->
      @directoryApi     = new DirectoryApi()
      @marshaller       = new CryptoServiceMarshaller()

    getRsaCryptoService: ->
      keypair = CredentialStore.credentialProvider.load().keypair
      return new RsaCryptoService(keypair.privateKey, keypair.publicKey)

    getObjectCryptoService: (id, options) ->
      options          = _.defaults({}, options, DEFAULT_OPTS)
      {expectMiss}     = options
      rsaCryptoService = @getRsaCryptoService()

      return  @directoryApi.getObjectCryptoService(id)
      .then (serializedCryptoService) =>
        if !serializedCryptoService && expectMiss
          logger.info('no cryptoService exists for this object. creating one on-the-fly', {id})
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
