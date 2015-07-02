define 'soteria.aes-crypto-service', [
  'require',
  'forge.min',
  'soteria.abstract-crypto-service'
], (require) ->
  'use strict';

  Forge                 = require('forge.min');
  AbstractCryptoService = require('soteria.abstract-crypto-service');

  BITS_PER_BYTE         = 8
  BLOCK_CIPHER_KEY_SIZE = 16

  class AesCryptoService

    constructor: (@cypher, @key) ->
      if not @key
        console.info('[AesCryptoService] no key passed! generating a key.')
        @key = Forge.random.getBytesSync(cypher.keySize / BITS_PER_BYTE);
      @abstractCryptoService = new AbstractCryptoService(cypher)

    encrypt: (plaintext) ->
      iv         = Forge.random.getBytesSync(BLOCK_CIPHER_KEY_SIZE)
      ciphertext = @abstractCryptoService.encrypt(@key, iv, plaintext)

      return {
        iv       : btoa(iv)
        salt     : btoa(Forge.random.getBytesSync(0))
        contents : btoa(ciphertext)
      }

    decrypt: (blockCiphertext) ->
      return @abstractCryptoService.decrypt(@key, atob(blockCiphertext.iv), atob(blockCiphertext.contents))

  return AesCryptoService