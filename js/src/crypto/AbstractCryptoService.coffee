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

    encrypt: (key, iv, plaintext) =>
      ciphertext = @encryptBuffer( key, iv, Forge.util.createBuffer(plaintext) )
      return ciphertext

    encryptBuffer: (key, iv, buffer) ->
      cipher = Forge.cipher.createCipher(@algorithm + '-' + @mode, key)
      cipher.start({ iv })
      cipher.update(buffer)
      cipher.finish()
      return cipher.output.data

    decrypt: (key, iv, ciphertext) =>
      buffer = @decryptToBuffer(key, iv, Forge.util.createBuffer(ciphertext))
      return buffer.data

    decryptToBuffer: (key, iv, buffer) ->
      decipher = Forge.cipher.createDecipher(@algorithm + '-' + @mode, key)
      decipher.start({ iv })
      decipher.update(buffer)
      decipher.finish()
      return decipher.output

  return AbstractCryptoService
