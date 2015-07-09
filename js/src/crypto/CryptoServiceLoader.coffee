define 'soteria.crypto-service-loader', [
  'require',
  'jquery',
  'forge',
  'soteria.logger'
  'soteria.cypher',
  'soteria.rsa-crypto-service',
  'soteria.aes-crypto-service'
  'soteria.directory-api'
  'soteria.crypto-service-marshaller'
  'soteria.authentication-service'
], (require) ->
  'use strict'

  jquery                  = require 'jquery'
  Forge                   = require 'forge'
  RsaCryptoService        = require 'soteria.rsa-crypto-service'
  AesCryptoService        = require 'soteria.aes-crypto-service'
  Cypher                  = require 'soteria.cypher'
  DirectoryApi            = require 'soteria.directory-api'
  Logger                  = require 'soteria.logger'
  CryptoServiceMarshaller = require 'soteria.crypto-service-marshaller'
  AuthenticationService   = require 'soteria.authentication-service'

  INT_SIZE     = 4
  EMPTY_BUFFER = ''

  logger = Logger.get('CryptoServiceLoader')

  #
  # Loads cryptoservices which can be used for object decryption.
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: ->
      @directoryApi     = new DirectoryApi()
      @marshaller       = new CryptoServiceMarshaller()

    getRsaCryptoService: ->
      keypair = AuthenticationService.credentialProvider.load().keypair
      return new RsaCryptoService(keypair.privateKey, keypair.publicKey)

    # TODO: this should take a {failOnLoad} flag so this can fail if the service can't be loaded.
    # we should only allow on-the-fly generation in cases where we are creating objects.
    getObjectCryptoService: (id) ->
      rsaCryptoService = @getRsaCryptoService()

      return  @directoryApi.getObjectCryptoService(id)
      .then (serializedCryptoService) =>
        if !serializedCryptoService
          logger.info('no cryptoService exists for this object. creating one on-the-fly', {id})
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoService( id, cryptoService )
          return cryptoService
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
