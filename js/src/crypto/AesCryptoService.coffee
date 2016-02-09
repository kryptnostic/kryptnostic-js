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

  logger = Logger.get('AesCryptoService')

  class AesCryptoService

    @BLOCK_CIPHER_KEY_SIZE : 16

    constructor: (@cypher, @key) ->

      if not @key
        logger.info('no key passed! generating a key.')
        @key = Forge.random.getBytesSync(@cypher.keySize / BITS_PER_BYTE)
      @abstractCryptoService = new AbstractCryptoService(@cypher)

    encrypt: (plaintext) ->

      iv         = Forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
      ciphertext = @abstractCryptoService.encrypt(@key, iv, plaintext)

      return new BlockCiphertext {
        iv       : btoa(iv)
        salt     : btoa(Forge.random.getBytesSync(0))
        contents : btoa(ciphertext)
      }

    encryptUint8Array: (uint8) ->

      iv         = Forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
      buffer     = Forge.util.createBuffer(uint8)
      ciphertext = @abstractCryptoService.encryptBuffer(@key, iv, buffer)

      return new BlockCiphertext {
        iv       : btoa(iv)
        salt     : btoa(Forge.random.getBytesSync(0))
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
