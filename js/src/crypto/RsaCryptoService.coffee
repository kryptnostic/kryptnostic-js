define 'soteria.rsa-crypto-service', [
  'require',
  'forge.min'
], (require) ->
  'use strict';

  Forge = require('forge.min');

  class RsaCryptoService

    # args are forge public and private key objects
    constructor: (@privateKey, @publicKey) ->

    encrypt: (plaintext) ->
      ciphertext = @publicKey.encrypt(plaintext, 'RSA-OAEP', {
        md : Forge.md.sha1.create()
      });
      return ciphertext;

    decrypt: (ciphertext) ->
      plaintext = @privateKey.decrypt(ciphertext, 'RSA-OAEP', {
        md : Forge.md.sha1.create()
      });
      return plaintext;

  return RsaCryptoService;
