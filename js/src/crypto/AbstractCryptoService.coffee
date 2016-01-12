define 'kryptnostic.abstract-crypto-service', [
  'require'
  'forge'
  'kryptnostic.binary-utils'
  'kryptnostic.crypto-algorithm'
], (require) ->

  # libraries
  Forge           = require 'forge'

  # kryptnostic
  CryptoAlgorithm = require 'kryptnostic.crypto-algorithm'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'

  # WebCrypto API
  webCryptoApi = null
  if window.crypto?.subtle? or window.msCrypto?.subtle?
    webCryptoApi = window.crypto or window.msCrypto

  class AbstractCryptoService

    constructor: (@cypher) ->
      unless @cypher.cipher is CryptoAlgorithm.AES and @cypher.mode is 'CTR'
        throw new Error 'cypher not implemented'

    @generateRandomBytes: (byteCount) ->
      if webCryptoApi
        randomBytes = webCryptoApi.getRandomValues(new Uint8Array(byteCount))
        return BinaryUtils.uint8ToString(randomBytes)
      else
        return Forge.random.getBytesSync(byteCount)


    encrypt: (key, iv, plaintext) =>
      # plaintextBuffer = null
      # if webCryptoApi
      #   plaintextBuffer = BinaryUtils.stringToUint8(plaintext)
      # else
      plaintextBuffer = Forge.util.createBuffer(plaintext)
      return @encryptBuffer(key, iv, plaintextBuffer)

    encryptBuffer: (key, iv, buffer) ->

      if webCryptoApi
        return webCryptoApi.subtle.encrypt(
          {
            name: @cypher.algorithm,
            length: @cypher.keySize,
            counter: BinaryUtils.stringToUint8(iv)
          },
          key,
          BinaryUtils.stringToUint8(buffer.data)
        )
        .then (encryptedDataAsArrayBuffer) ->
          encryptedDataAsUint8Array = new Uint8Array(encryptedDataAsArrayBuffer)
          return BinaryUtils.uint8ToString(encryptedDataAsUint8Array)
        .catch (err) ->
          console.log(err)
      else
        cipher = Forge.cipher.createCipher(@algorithm, key)
        cipher.start({ iv })
        cipher.update(buffer)
        cipher.finish()
        return Promise.resolve(cipher.output.data)

    decrypt: (key, iv, ciphertext) =>
      # ciphertextBuffer = null
      # if webCryptoApi
      #   ciphertextBuffer = BinaryUtils.stringToUint8(ciphertext)
      # else
      ciphertextBuffer = Forge.util.createBuffer(ciphertext)

      Promise.resolve(
        @decryptToBuffer(key, iv, ciphertextBuffer)
      )
      .then (buffer) ->
        return buffer

    decryptToBuffer: (key, iv, buffer) ->

      if webCryptoApi
        return webCryptoApi.subtle.decrypt(
          {
            name: @cypher.algorithm,
            length: @cypher.keySize,
            counter: BinaryUtils.stringToUint8(iv)
          },
          key,
          BinaryUtils.stringToUint8(buffer.data)
        )
        .then (decryptedDataAsArrayBuffer) ->
          decryptedDataAsUint8Array = new Uint8Array(decryptedDataAsArrayBuffer)
          return BinaryUtils.uint8ToString(decryptedDataAsUint8Array)
        .catch (err) ->
          console.log(err)
      else
        decipher = Forge.cipher.createDecipher(@algorithm, key)
        decipher.start({ iv })
        decipher.update(buffer)
        decipher.finish()
        return Promise.resolve(decipher.output)

  return AbstractCryptoService
