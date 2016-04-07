define 'kryptnostic.aes-crypto-service', [
  'require'
  'forge'
  'kryptnostic.abstract-crypto-service'
  'kryptnostic.binary-utils'
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

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'
  Logger      = require 'kryptnostic.logger'

  # constants
  EMPTY_STRING = ''
  BITS_PER_BYTE = 8
  HMAC_HASH_FUNCTION = 'sha256'
  IV_96 = 96
  IV_128 = 128

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

    constructor: (@cypher, @key) ->

      # default to AES_CTR_128
      if not @cypher
        @cypher = Cypher.AES_CTR_128

      # generate a random AES key if one is not given
      if not @key
        @key = forge.random.getBytesSync(@cypher.keySize / BITS_PER_BYTE)

      @abstractCryptoService = new AbstractCryptoService(@cypher)

    encrypt: (plaintext) ->

      { iv, salt, ciphertext, tag } = {}

      salt = EMPTY_STRING

      if @cypher.mode == Cypher.AES_GCM_256.mode
        iv = forge.random.getBytesSync(IV_96 / BITS_PER_BYTE)
      else
        iv = forge.random.getBytesSync(IV_128 / BITS_PER_BYTE)

      if @cypher.mode is Cypher.AES_GCM_256.mode
        cipherOutput = @abstractCryptoService.encrypt(@key, iv, plaintext)
        ciphertext = cipherOutput.ciphertext
        tag = cipherOutput.tag.getBytes()
      else
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

    encryptUint8Array: (plaintextAsUint8) ->

      plaintext = BinaryUtils.uint8ToString(plaintextAsUint8)
      return @encrypt(plaintext)

    decrypt: (blockCipherText) ->

      { iv, salt, ciphertext, tag } = {}

      iv         = atob(blockCipherText.iv)
      salt       = atob(blockCipherText.salt)
      ciphertext = atob(blockCipherText.contents)

      if not _.isEmpty(blockCipherText.tag)
        tag = atob(blockCipherText.tag)

      if @cypher.mode is Cypher.AES_GCM_256.mode
        return @abstractCryptoService.decrypt(@key, iv, ciphertext, tag)
      else
        isValid = true
        if not _.isEmpty(tag)
          isValid = checkDataIntegrity(@key, iv, salt, ciphertext, tag)
        if not isValid
          throw new Error('BlockCipherText data integrity check failed')
        return @abstractCryptoService.decrypt(@key, iv, ciphertext)

    decryptToUint8Array: (blockCipherText) ->

      plaintext = @decrypt(blockCipherText)
      return new Uint8Array(_.map(plaintext, (c) -> c.charCodeAt() ) )

  return AesCryptoService
