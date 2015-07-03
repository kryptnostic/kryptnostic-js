define 'soteria.crypto-service-loader', [
  'require',
  'jquery',
  'forge.min',
  'pako',
  'soteria.logger'
  'soteria.security-utils',
  'soteria.cypher',
  'soteria.password-crypto-service',
  'soteria.rsa-crypto-service',
  'soteria.aes-crypto-service'
  'soteria.directory-api'
], (require) ->
  'use strict'

  jquery                = require 'jquery'
  Forge                 = require 'forge.min'
  Pako                  = require 'pako'
  PasswordCryptoService = require 'soteria.password-crypto-service'
  RsaCryptoService      = require 'soteria.rsa-crypto-service'
  AesCryptoService      = require 'soteria.aes-crypto-service'
  SecurityUtils         = require 'soteria.security-utils'
  Cypher                = require 'soteria.cypher'
  DirectoryApi          = require 'soteria.directory-api'
  Logger                = require 'soteria.logger'

  INT_SIZE     = 4
  EMPTY_BUFFER = ''

  logger = Logger.get('CryptoServiceLoader')

  #
  # Loads cryptoservices which can be used for object decryption.
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: (password) ->
      @directoryApi          = new DirectoryApi()
      @passwordCryptoService = new PasswordCryptoService(password)
      @rsaCryptoService      = undefined

    getPasswordCryptoService: ->
      return @passwordCryptoService

    getRsaCryptoService: ->
      deferred = new jquery.Deferred();

      unless @rsaCryptoService?
        @loadRsaKeys().then((keypair) =>
          @rsaCryptoService = new RsaCryptoService(keypair.privateKey, keypair.publicKey);
          deferred.resolve(@rsaCryptoService);
        )
      else
        deferred.resolve(@rsaCryptoService);

      return deferred.promise();

    # TODO failure flag
    getObjectCryptoService: (id) ->
      deferred              = new jquery.Deferred();

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
          deflatedCryptoService     = rsaCryptoService.decrypt(atob(serializedCryptoService))
          buffer                    = Forge.util.createBuffer(deflatedCryptoService, 'raw')
          discardBytes              = buffer.getBytes(INT_SIZE) # prepended length integer
          compBytes                 = buffer.getBytes(buffer.length())
          decompressedCryptoService = JSON.parse(Pako.inflate(compBytes, {to: 'string'}))
          objectCryptoService       = new AesCryptoService(
            decompressedCryptoService.cypher,
            atob(decompressedCryptoService.key)
          );
          deferred.resolve(objectCryptoService);

      return deferred.promise();

    setObjectCryptoService: (id, cryptoService) ->
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')

      # extract compressible fields into a raw object and stringify
      {key, cypher}           = cryptoService
      rawCryptoService        = {cypher, key: btoa(key)}
      serializedCryptoService = JSON.stringify(rawCryptoService)

      # compress the stringified cryptoservice, it will become part of payload
      compressedCryptoService = Pako.deflate(serializedCryptoService, {to: 'string'})

      # determine size of the compressed cryptoService
      cryptoServiceBuffer = Forge.util.createBuffer(EMPTY_BUFFER, 'raw')
      cryptoServiceBuffer.putBytes(compressedCryptoService)
      cryptoServiceByteCount = cryptoServiceBuffer.length()

      # serialize everything into a buffer for transport
      messageBuffer = Forge.util.createBuffer(EMPTY_BUFFER, 'raw')
      messageBuffer.putInt32(cryptoServiceByteCount)
      messageBuffer.putBytes(compressedCryptoService)

      # encrypt the resulting message buffer and send it
      @getRsaCryptoService()
      .then (rsaCryptoService) =>
        encryptedCryptoService = rsaCryptoService.encrypt(messageBuffer.data)
        return @directoryApi.setObjectCryptoService(id, encryptedCryptoService)

    loadRsaKeys: ->
      deferred = new jquery.Deferred();
      request  = @directoryApi.getRsaKeys()

      resolveRsaKeys = (blockCiphertext) =>
        privateKeyBytes  = @getPasswordCryptoService().decrypt(blockCiphertext)
        privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
        privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
        privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
        publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

        deferred.resolve({privateKey, publicKey})

      request.done(resolveRsaKeys);
      request.fail( -> deferred.reject() );
      return deferred.promise();

  return CryptoServiceLoader;
