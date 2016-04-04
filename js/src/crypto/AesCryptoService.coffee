define 'kryptnostic.aes-crypto-service', [
  'require'
  'forge'
  'kryptnostic.abstract-crypto-service'
  'kryptnostic.block-ciphertext'
  'kryptnostic.cypher'
  'kryptnostic.logger'
], (require) ->
  'use strict'

  # libraries
  forge = require 'forge'

  # kryptnostic
  AbstractCryptoService = require 'kryptnostic.abstract-crypto-service'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'
  Cypher                = require 'kryptnostic.cypher'

  # schemas
  BLOCK_CIPHERTEXT_SCHEMA = require 'kryptnostic.schema.block-ciphertext'

  # utils
  Logger    = require 'kryptnostic.logger'
  Validator = require 'kryptnostic.schema.validator'

  # constants
  BITS_PER_BYTE = 8
  HMAC_HASH_FUNCTION = 'sha256'

  logger = Logger.get('AesCryptoService')

  computeHMAC = (key, iv, salt, ciphertext) ->
    try
      hmac = forge.hmac.create()
      hmac.start(HMAC_HASH_FUNCTION, key)
      hmac.update(iv)
      hmac.update(salt)
      hmac.update(ciphertext)
      hmacHash = hmac.digest().getBytes()
      return hmacHash
    catch e
      logger.error('caught exception while computing HMAC')
      return null

  checkDataIntegrity = (key, iv, salt, ciphertext, tag) ->
    hmacHash = computeHMAC(key, iv, salt, ciphertext)
    return tag == hmacHash

  class AesCryptoService

    #
    # HACK!!! - uglfifying changes constructor.name, so we can't rely on the name property
    #
    _CLASS_NAME: 'AesCryptoService'
    @_CLASS_NAME: 'AesCryptoService'

    @BLOCK_CIPHER_KEY_SIZE : 16

    constructor: (@cypher, @key) ->

      if not @key
        logger.info('no key passed! generating a key.')
        @key = forge.random.getBytesSync(@cypher.keySize / BITS_PER_BYTE)
      @abstractCryptoService = new AbstractCryptoService(@cypher)

    encrypt: (plaintext) ->

      { iv, salt, ciphertext, tag } = {}

      iv = forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
      salt = forge.random.getBytesSync(0)

      if @cypher.mode is Cypher.AES_GCM_128.mode
        cipherOutput = @abstractCryptoService.encrypt(@key, iv, plaintext)
        ciphertext = cipherOutput.ciphertext
        tag = cipherOutput.tag
      else if @cypher.mode is Cypher.AES_CTR_128.mode
        ciphertext = @abstractCryptoService.encrypt(@key, iv, plaintext)
        hmacHash = computeHMAC(@key, iv, salt, ciphertext)
        if hmacHash?
          tag = hmacHash

      return new BlockCiphertext({
        iv       : btoa(iv)
        salt     : btoa(salt)
        contents : btoa(ciphertext)
        tag      : btoa(tag)
      })

    encryptUint8Array: (uint8) ->

      { iv, salt, ciphertext, tag } = {}

      iv = forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
      salt = forge.random.getBytesSync(0)
      buffer = forge.util.createBuffer(uint8)

      if @cypher.mode is Cypher.AES_GCM_128.mode
        cipherOutput = @abstractCryptoService.encryptBuffer(@key, iv, buffer)
        ciphertext = cipherOutput.ciphertext
        tag = cipherOutput.tag
      else if @cypher.mode is Cypher.AES_CTR_128.mode
        ciphertext = @abstractCryptoService.encryptBuffer(@key, iv, buffer)
        hmacHash = computeHMAC(@key, iv, salt, ciphertext)
        if hmacHash?
          tag = hmacHash

      return new BlockCiphertext({
        iv       : btoa(iv)
        salt     : btoa(salt)
        contents : btoa(ciphertext)
        tag      : btoa(tag)
      })

    decrypt: (blockCipherText) ->

      Validator.validate(blockCipherText, BlockCiphertext, BLOCK_CIPHERTEXT_SCHEMA)

      { iv, salt, ciphertext, tag } = {}

      iv         = atob(blockCipherText.iv)
      salt       = atob(blockCipherText.salt)
      ciphertext = atob(blockCipherText.contents)

      if not _.isEmpty(blockCipherText.tag)
        tag = atob(blockCipherText.tag)

      if @cypher.mode is Cypher.AES_GCM_128.mode
        return @abstractCryptoService.decrypt(@key, iv, ciphertext, tag)
      else if @cypher.mode is Cypher.AES_CTR_128.mode
        isValid = checkDataIntegrity(@key, iv, salt, ciphertext, tag)
        if not isValid
          throw new Error('BlockCipherText data integrity check failed')
        return @abstractCryptoService.decrypt(@key, iv, ciphertext)

    decryptToUint8Array: (blockCipherText) ->

      plaintext = @decrypt(blockCipherText)
      return new Uint8Array(_.map(plaintext, (c) -> c.charCodeAt() ) )

  return AesCryptoService
