define 'soteria.crypto-service-loader', [
  'require',
  'jquery',
  'cookies',
  'forge.min',
  'pako',
  'soteria.security-utils',
  'soteria.cypher',
  'soteria.password-crypto-service',
  'soteria.rsa-crypto-service',
  'soteria.aes-crypto-service'
  'soteria.directory-api'
], (require) ->
  'use strict'

  jquery                = require('jquery')
  Cookies               = require('cookies')
  Forge                 = require('forge.min')
  Pako                  = require('pako')
  PasswordCryptoService = require('soteria.password-crypto-service')
  RsaCryptoService      = require('soteria.rsa-crypto-service')
  AesCryptoService      = require('soteria.aes-crypto-service')
  SecurityUtils         = require('soteria.security-utils')
  Cypher                = require('soteria.cypher')
  DirectoryApi          = require('soteria.directory-api')

  INT_SIZE = 4


  log = (message, args...) ->
    console.info("[CryptoServiceLoader] #{message} #{args.map(JSON.stringify)}")

  #
  # Loads cryptoservices which can be used for object decryption.
  #
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: (password) ->
      @directoryApi      = new DirectoryApi()
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
          log('no cryptoService exists for this object. creating one on-the-fly', {id})
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoService( id, cryptoService )
          deferred.resolve(cryptoService)
        else
          deflatedCryptoService     = rsaCryptoService.decrypt(atob(serializedCryptoService))
          buffer                    = Forge.util.createBuffer(deflatedCryptoService, 'raw')
          discardBytes              = buffer.getBytes(INT_SIZE) # prepended length integer
          compBytes                 = buffer.getBytes(buffer.length())
          decompressedCryptoService = JSON.parse(Pako.inflate(compBytes, { to : 'string' }))
          log('decompressed loaded crypto service: ', decompressedCryptoService)
          objectCryptoService       = new AesCryptoService(
            decompressedCryptoService.cypher,
            atob(decompressedCryptoService.key)
          );
          deferred.resolve(objectCryptoService);

      return deferred.promise();

    setObjectCryptoService : (id, cryptoService) ->
      unless cryptoService.constructor.name is 'AesCryptoService'
        throw new Error('serialization only implemented for AesCryptoService')



      console.error('[CryptoServiceLoader] setObjectCryptoService is not implemented!')

    loadRsaKeys : ->
      deferred = new jquery.Deferred();
      request  = @directoryApi.getRsaKeys()

      resolveRsaKeys = (blockCiphertext) =>
        privateKeyBytes  = @getPasswordCryptoService().decrypt(blockCiphertext)
        privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
        privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
        privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
        publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

        deferred.resolve({
          privateKey : privateKey,
          publicKey  : publicKey
        });

      request.done(resolveRsaKeys);
      request.fail( -> deferred.reject() );
      return deferred.promise();

  return CryptoServiceLoader;
