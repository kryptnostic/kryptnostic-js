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

  BASE_URL = 'http://localhost:8081/v1'
  DIR_URL  = '/directory'
  PUB_URL  = '/public'
  PRIV_URL = '/private'
  OBJ_URL  = '/object'
  INT_SIZE = 4

  loadCryptoService = (id) ->
    return jquery.ajax(SecurityUtils.wrapRequest({
      url  : BASE_URL + DIR_URL + OBJ_URL + '/' + id,
      type : 'GET'
    }))

  #
  # Loads cryptoservices which can be used for object decryption.
  #
  # Author: nickdhewitt, rbuckheit
  #
  class CryptoServiceLoader

    constructor: (password) ->
      @passwordCryptoService = new PasswordCryptoService(password)
      @rsaCryptoService      = undefined

    getPasswordCryptoService: ->
      return @passwordCryptoService

    getRsaCryptoService: ->
      deferred = new jquery.Deferred();

      if @rsaCryptoService is 'undefined'
        @loadRsaKeys().then((keypair) =>
          @rsaCryptoService = new RsaCryptoService(keypair.privateKey, keypair.publicKey);
          deferred.resolve(@rsaCryptoService);
        )
      else
        deferred.resolve(@rsaCryptoService);

      return deferred.promise();

    getObjectCryptoService: (id) ->
      deferred              = new jquery.Deferred();

      jquery.when(
        @getRsaCryptoService(),
        loadCryptoService(id)
      ).then (rsaCryptoService, cryptoServiceResponse) =>

        serializedCryptoService = cryptoServiceResponse[0].data;

        if !serializedCryptoService
          console.info('[CryptoServiceLoader] cryptoservice could not be loaded. creating on-the-fly using defaults.')
          cryptoService = new AesCryptoService( Cypher.AES_CTR_128 )
          @setObjectCryptoService( id, cryptoService )
          deferred.resolve(cryptoService)
        else
          deflatedCryptoService = rsaCryptoService.decrypt(atob(cryptoServiceResponse[0].data))
          buffer = Forge.util.createBuffer(deflatedCryptoService, 'raw')
          buffer.getBytes(INT_SIZE); # remove the prepended length integer
          compBytes = buffer.getBytes(buffer.length());
          decompressedCryptoService = JSON.parse(Pako.inflate(compBytes, { to : 'string' }));
          objectCryptoService = new AesCryptoService(
            decompressedCryptoService.cypher,
            atob(decompressedCryptoService.key)
          );
          deferred.resolve(objectCryptoService);

      return deferred.promise();


    setObjectCryptoService : (id, cryptoService) ->
      console.error('[CryptoServiceLoader] setObjectCryptoService is not implemented!')

      # private
      # =======

    loadRsaKeys : ->
      deferred = new jquery.Deferred();
      request  = jquery.ajax(SecurityUtils.wrapRequest({
        url  : BASE_URL + DIR_URL + PRIV_URL,
        type : 'GET'
      }));

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
