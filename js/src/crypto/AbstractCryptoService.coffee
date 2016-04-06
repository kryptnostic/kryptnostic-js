# coffeelint: disable=cyclomatic_complexity
 
define 'kryptnostic.abstract-crypto-service', [
  'require'
  'forge'
  'kryptnostic.crypto-algorithm'
], (require) ->

  Forge           = require 'forge'
  CryptoAlgorithm = require 'kryptnostic.crypto-algorithm'

  class AbstractCryptoService

    #
    # HACK!!! - uglfifying changes constructor.name, so we can't rely on the name property
    #
    _CLASS_NAME: 'AbstractCryptoService'
    @_CLASS_NAME: 'AbstractCryptoService'

    constructor: ({ @algorithm, @mode }) ->
      unless @algorithm is CryptoAlgorithm.AES and @mode in ['CTR', 'GCM']
        throw new Error 'cypher not implemented'

    encrypt: (key, iv, plaintext) =>
      ciphertext = @encryptBuffer( key, iv, Forge.util.createBuffer(plaintext) )
      return ciphertext

    encryptBuffer: (key, iv, buffer) ->
      cipher = Forge.cipher.createCipher(@algorithm + '-' + @mode, key)
      cipher.start({ iv })
      cipher.update(buffer)
      cipher.finish()
      if @mode is 'GCM'
        return { 'ciphertext': cipher.output.data, 'tag': cipher.mode.tag }
      else
        return cipher.output.data

    decrypt: (key, iv, ciphertext, tag) =>
      if tag? && @mode is not 'GCM'
        throw new Error 'CTR does not require a tag'
      if @mode is 'GCM' && !tag?
        throw new Error 'GCM requires an auth tag for decryption'

      if @mode is 'GCM'
        buffer = @decryptToBuffer(key, iv, Forge.util.createBuffer(ciphertext), tag)
      else
        buffer = @decryptToBuffer(key, iv, Forge.util.createBuffer(ciphertext))
      return buffer.data

    decryptToBuffer: (key, iv, buffer, tag) ->
      decipher = Forge.cipher.createDecipher(@algorithm + '-' + @mode, key)
      if tag? && @mode is not 'GCM'
        throw new Error 'CTR does not require a tag'
      if @mode is 'GCM' && !tag?
        throw new Error 'GCM requires an auth tag for decryption'

      if @mode is 'GCM'
        decipher.start({ 'iv': iv, 'tag': tag })
      else
        decipher.start({ iv })
      decipher.update(buffer)
      decipher.finish()
      return decipher.output

  return AbstractCryptoService
