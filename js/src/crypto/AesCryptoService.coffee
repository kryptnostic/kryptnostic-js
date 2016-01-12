define 'kryptnostic.aes-crypto-service', [
  'require'
  'forge'
  'kryptnostic.abstract-crypto-service'
  'kryptnostic.logger'
  'kryptnostic.block-ciphertext'
], (require) ->
  'use strict'

  # libraries
  Forge = require 'forge'

  # kryptnostic
  AbstractCryptoService = require 'kryptnostic.abstract-crypto-service'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'

  # schemas
  BLOCK_CIPHERTEXT_SCHEMA = require 'kryptnostic.schema.block-ciphertext'

  # utils
  Logger    = require 'kryptnostic.logger'
  Validator = require 'kryptnostic.schema.validator'

  # constants
  BITS_PER_BYTE = 8
  BLOCK_CIPHER_KEY_SIZE = 16

  logger = Logger.get('AesCryptoService')

  # WebCrypto API
  webCryptoApi = null
  if window.crypto?.subtle? or window.msCrypto?.subtle?
    webCryptoApi = window.crypto or window.msCrypto

  class AesCryptoService

    constructor: (@cypher, @key) ->
      if not @key
        throw new Error('key is required')

      @abstractCryptoService = new AbstractCryptoService(cypher)

    @get = (cypher) ->
      Promise.resolve()
      .then =>
        if webCryptoApi
          return webCryptoApi.subtle.generateKey(
            {
              name: cypher.algorithm,
              length: cypher.keySize
            },
            true,
            ['encrypt', 'decrypt']
          )
        else
          return Promise.resolve(
            Forge.random.getBytesSync(cypher.keySize / BITS_PER_BYTE)
          )
      .then (key) =>
        return new AesCryptoService(cypher, key)

    encrypt: (plaintext) ->
      iv   = AbstractCryptoService.generateRandomBytes(BLOCK_CIPHER_KEY_SIZE)
      salt = '' # Forge.random.getBytesSync(0)
      Promise.resolve(
        @abstractCryptoService.encrypt(@key, iv, plaintext)
      )
      .then (ciphertext) ->
        return new BlockCiphertext {
          iv       : btoa(iv)
          salt     : btoa(salt)
          contents : btoa(ciphertext)
        }

    encryptUint8Array: (uint8) ->

      iv     = AbstractCryptoService.generateRandomBytes(BLOCK_CIPHER_KEY_SIZE)
      salt   = '' # Forge.random.getBytesSync(0)
      buffer = Forge.util.createBuffer(uint8)

      Promise.resolve(
        @abstractCryptoService.encryptBuffer(@key, iv, buffer)
      )
      .then (ciphertext) =>
        return new BlockCiphertext {
          iv       : btoa(iv)
          salt     : btoa(salt)
          contents : btoa(ciphertext)
        }

    decrypt: (blockCipherText) ->

      Validator.validate(blockCipherText, BlockCiphertext, BLOCK_CIPHERTEXT_SCHEMA)

      iv       = atob(blockCipherText.iv)
      contents = atob(blockCipherText.contents)
      return @abstractCryptoService.decrypt(@key, iv, contents)

    decryptToUint8Array: (blockCipherText) ->

      plaintext = @decrypt(blockCipherText)
      return new Uint8Array(_.map(plaintext, (c) -> c.charCodeAt() ) )

  return AesCryptoService
