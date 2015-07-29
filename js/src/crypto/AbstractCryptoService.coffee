define 'kryptnostic.abstract-crypto-service', [
  'require'
  'forge'
  'kryptnostic.crypto-algorithm'
], (require) ->

  Forge           = require 'forge'
  CryptoAlgorithm = require 'kryptnostic.crypto-algorithm'

  #
  # Author: nickdhewitt, rbuckheit
  #
  class AbstractCryptoService

    constructor: ({ @algorithm, @mode }) ->
      unless @algorithm is CryptoAlgorithm.AES and @mode is 'CTR'
        throw new Error 'cypher not implemented'

    encrypt: (key, iv, plaintext) ->
      cipher = Forge.cipher.createCipher(@algorithm + '-' + @mode, key)
      cipher.start({ iv })
      cipher.update(Forge.util.createBuffer(plaintext))
      cipher.finish()
      return cipher.output.data

    decrypt: (key, iv, ciphertext) ->
      decipher = Forge.cipher.createDecipher(@algorithm + '-' + @mode, key)
      decipher.start({ iv })
      decipher.update(Forge.util.createBuffer(ciphertext))
      decipher.finish()
      return decipher.output.data

  return AbstractCryptoService
