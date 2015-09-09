define 'kryptnostic.aes-crypto-service', [
  'require',
  'forge',
  'kryptnostic.abstract-crypto-service'
  'kryptnostic.logger'
  'kryptnostic.block-ciphertext'
], (require) ->
  'use strict'

  Forge                 = require 'forge'
  AbstractCryptoService = require 'kryptnostic.abstract-crypto-service'
  Logger                = require 'kryptnostic.logger'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'

  logger = Logger.get('AesCryptoService')

  BITS_PER_BYTE         = 8

  #
  # Author: nickdhewitt, rbuckheit
  #
  class AesCryptoService

    @BLOCK_CIPHER_KEY_SIZE : 16

    constructor: (@cypher, @key) ->
      if not @key
        logger.info('no key passed! generating a key.')
        @key = Forge.random.getBytesSync(cypher.keySize / BITS_PER_BYTE)
      @abstractCryptoService = new AbstractCryptoService(cypher)

    encrypt: (plaintext) ->
      iv         = Forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
      ciphertext = @abstractCryptoService.encrypt(@key, iv, plaintext)

      return new BlockCiphertext {
        iv       : btoa(iv)
        salt     : btoa(Forge.random.getBytesSync(0))
        contents : btoa(ciphertext)
      }

    encryptUint8Array: ( uint8 ) ->
      iv         = Forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
      buffer     = Forge.util.createBuffer(uint8)
      ciphertext = @abstractCryptoService.encryptBuffer(@key, iv, buffer)

      return new BlockCiphertext {
        iv       : btoa(iv)
        salt     : btoa(Forge.random.getBytesSync(0))
        contents : btoa(ciphertext)
      }

    decrypt: (blockCiphertext) ->
      iv       = atob(blockCiphertext.iv)
      contents = atob(blockCiphertext.contents)
      return @abstractCryptoService.decrypt(@key, iv, contents)

    decryptToUint8Array: (blockCiphertext) ->
      plaintext = @decrypt(blockCiphertext)
      return new Uint8Array(_.map(plaintext, (c) -> c.charCodeAt() ) )

  return AesCryptoService
