define 'soteria.crypto-service-loader', [
  'require',
  'jquery',
  'forge',
  'soteria.logger'
  'soteria.security-utils',
  'soteria.cypher',
  'soteria.password-crypto-service',
  'soteria.rsa-crypto-service',
  'soteria.aes-crypto-service'
  'soteria.directory-api'
  'soteria.crypto-service-marshaller'
], (require) ->
  'use strict'

  jquery                  = require 'jquery'
  Forge                   = require 'forge'
  PasswordCryptoService   = require 'soteria.password-crypto-service'
  RsaCryptoService        = require 'soteria.rsa-crypto-service'
  AesCryptoService        = require 'soteria.aes-crypto-service'
  SecurityUtils           = require 'soteria.security-utils'
  Cypher                  = require 'soteria.cypher'
  DirectoryApi            = require 'soteria.directory-api'
  Logger                  = require 'soteria.logger'
  CryptoServiceMarshaller = require 'soteria.crypto-service-marshaller'

  INT_SIZE     = 4
  EMPTY_BUFFER = ''

  logger = Logger.get('CryptoServiceLoader')

  #
  # Loads cryptoservices which can be used for object decryption.
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: (password) ->
      @directoryApi            = new DirectoryApi()
      @passwordCryptoService   = new PasswordCryptoService(password)
      @marshaller = new CryptoServiceMarshaller()
      @rsaCryptoService        = undefined

    getPasswordCryptoService: ->
      return @passwordCryptoService

    getRsaCryptoService: ->
      deferred = new jquery.Deferred()

      unless @rsaCryptoService?
        @loadRsaKeys().then((keypair) =>
          @rsaCryptoService = new RsaCryptoService(keypair.privateKey, keypair.publicKey)
          deferred.resolve(@rsaCryptoService)
        )
      else
        deferred.resolve(@rsaCryptoService)

      return deferred.promise()

    # TODO failure flag
    getObjectCryptoService: (id) ->
      deferred              = new jquery.Deferred()

      jquery.when(
        @getRsaCryptoService(),
        @directoryApi.getObjectCryptoService(id)
      ).then (rsaCryptoService, serializedCryptoService) =>

        if !serializedCryptoService
          logger.log('no cryptoService exists for this object. creating one on-the-fly', {id})
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoService( id, cryptoService )
          deferred.resolve(cryptoService)
        else
          objectCryptoService = @marshaller.unmarshall(serializedCryptoService, rsaCryptoService)
          deferred.resolve(objectCryptoService)

      return deferred.promise()

    setObjectCryptoService: (id, cryptoService) ->
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')

      marshalled = @marshaller.marshall(cryptoService)

      @getRsaCryptoService()
      .then (rsaCryptoService) =>
        encryptedCryptoService = rsaCryptoService.encrypt(marshalled)
        return @directoryApi.setObjectCryptoService(id, encryptedCryptoService)

    loadRsaKeys: ->
      deferred = new jquery.Deferred()
      request  = @directoryApi.getRsaKeys()

      resolveRsaKeys = (blockCiphertext) =>
        privateKeyBytes  = @getPasswordCryptoService().decrypt(blockCiphertext)
        privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
        privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
        privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
        publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

        deferred.resolve({privateKey, publicKey})

      request.done(resolveRsaKeys)
      request.fail( -> deferred.reject() )
      return deferred.promise()

  return CryptoServiceLoader
