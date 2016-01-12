define 'kryptnostic.password-crypto-service', [
  'require',
  'forge',
  'kryptnostic.abstract-crypto-service',
  'kryptnostic.binary-utils',
  'kryptnostic.block-ciphertext',
  'kryptnostic.cypher'
], (require) ->
  'use strict'

  Forge                 = require 'forge'
  AbstractCryptoService = require 'kryptnostic.abstract-crypto-service'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'
  Cypher                = require 'kryptnostic.cypher'

  # WebCrypto API
  webCryptoApi = null
  if window.crypto?.subtle? or window.msCrypto?.subtle?
    webCryptoApi = window.crypto or window.msCrypto

  deriveKey = (password, salt, iterations, keySize) ->
    if webCryptoApi
      return Promise.resolve(
        webCryptoApi.subtle.importKey(
          'raw',
          BinaryUtils.stringToUint8(password),
          { name: 'PBKDF2' },
          false,
          ['deriveKey']
        )
      )
      .then (baseKey) ->
        return Promise.resolve(
          webCryptoApi.subtle.deriveKey(
            {
                name       : 'PBKDF2',
                salt       : BinaryUtils.stringToUint8(salt),
                iterations : iterations,
                hash       : 'SHA-1'
            },
            baseKey,
            {
              name: 'AES-CTR',
              length: 128
            },
            true,
            ['encrypt', 'decrypt']
          )
        )
        .then (key) ->
          return key
        .catch (err) ->
          console.log(err)
    else
      return Promise.resolve(
        Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, Forge.sha1.create())
      )

  class PasswordCryptoService

    @BLOCK_CIPHER_ITERATIONS : 128

    @BLOCK_CIPHER_KEY_SIZE   : 16

    constructor: ->
      @abstractCryptoService = new AbstractCryptoService(Cypher.AES_CTR_128)

    encrypt: (plaintext, password) ->
      blockCipherKeySize    = PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE
      blockCipherIterations = PasswordCryptoService.BLOCK_CIPHER_ITERATIONS

      iv   = AbstractCryptoService.generateRandomBytes(blockCipherKeySize)
      salt = AbstractCryptoService.generateRandomBytes(blockCipherKeySize)

      Promise.resolve(
        deriveKey(password, salt, blockCipherIterations, blockCipherKeySize)
      )
      .then (key) =>
        Promise.resolve(
          @abstractCryptoService.encrypt(key, iv, plaintext)
        )
        .then (contents) =>
          return new BlockCiphertext {
            contents : btoa(contents)
            iv       : btoa(iv)
            salt     : btoa(salt)
          }

    decrypt: (blockCiphertext, password) ->
      blockCipherKeySize    = PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE
      blockCipherIterations = PasswordCryptoService.BLOCK_CIPHER_ITERATIONS

      iv       = atob(blockCiphertext.iv)
      salt     = atob(blockCiphertext.salt)
      contents = atob(blockCiphertext.contents)

      Promise.resolve(
        deriveKey(password, salt, blockCipherIterations, blockCipherKeySize)
      )
      .then (key) =>
        Promise.resolve(
          @abstractCryptoService.decrypt(key, iv, contents)
        )
        .then (decrypted) ->
          return decrypted

  return PasswordCryptoService
