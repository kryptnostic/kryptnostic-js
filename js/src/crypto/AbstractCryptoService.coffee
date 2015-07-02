define 'soteria.abstract-crypto-service', [
  'require'
  'lodash'
  'forge.min'
], (require) ->

  Forge = require 'forge.min'
  _     = require 'lodash'

  class AbstractCryptoService

    constructor: (cypher) ->
      unless cypher.algorithm is 'AES' and cypher.mode is 'CTR'
        throw new Error('Cypher not implemented')
      @algorithm = cypher.algorithm
      @mode      = cypher.mode

    encrypt: (key, iv, plaintext) ->
      cipher = Forge.cipher.createCipher(@algorithm + '-' + @mode, key);
      cipher.start({iv})
      cipher.update(Forge.util.createBuffer(plaintext));
      cipher.finish();
      return cipher.output.data;

    decrypt: (key, iv, ciphertext) ->
      decipher = Forge.cipher.createDecipher(@algorithm + '-' + @mode, key);
      decipher.start({iv})
      decipher.update(Forge.util.createBuffer(ciphertext));
      decipher.finish();
      return decipher.output.data;

  return AbstractCryptoService
