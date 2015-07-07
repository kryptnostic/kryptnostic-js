define 'soteria.abstract-crypto-service', [
  'require'
  'lodash'
  'forge'
  'soteria.crypto-algorithm'
], (require) ->

  Forge           = require 'forge'
  _               = require 'lodash'
  CryptoAlgorithm = require 'soteria.crypto-algorithm'

  #
  # Author: nickdhewitt, rbuckheit
  #
  class AbstractCryptoService

    constructor: (cypher) ->
      unless cypher.algorithm is CryptoAlgorithm.AES and cypher.mode is 'CTR'
        throw new Error('Cypher not implemented')
      @algorithm = cypher.algorithm
      @mode      = cypher.mode

    encrypt: (key, iv, plaintext) ->
      cipher = Forge.cipher.createCipher(@algorithm + '-' + @mode, key)
      cipher.start({iv})
      cipher.update(Forge.util.createBuffer(plaintext))
      cipher.finish()
      return cipher.output.data

    decrypt: (key, iv, ciphertext) ->
      decipher = Forge.cipher.createDecipher(@algorithm + '-' + @mode, key)
      decipher.start({iv})
      decipher.update(Forge.util.createBuffer(ciphertext))
      decipher.finish()
      return decipher.output.data

  return AbstractCryptoService
