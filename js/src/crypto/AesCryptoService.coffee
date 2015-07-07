define 'soteria.aes-crypto-service', [
  'require',
  'forge',
  'soteria.abstract-crypto-service'
  'soteria.logger'
], (require) ->
  'use strict'

  Forge                 = require 'forge'
  AbstractCryptoService = require 'soteria.abstract-crypto-service'
  Logger                = require 'soteria.logger'

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

      return {
        iv       : btoa(iv)
        salt     : btoa(Forge.random.getBytesSync(0))
        contents : btoa(ciphertext)
      }

    decrypt: (blockCiphertext) ->
      iv       = atob(blockCiphertext.iv)
      contents = atob(blockCiphertext.contents)
      return @abstractCryptoService.decrypt(@key, iv, contents)

  return AesCryptoService
