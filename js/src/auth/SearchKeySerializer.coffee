define 'kryptnostic.search-key-serializer', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.binary-utils'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.credential-loader'
  'kryptnostic.chunking.strategy.default'
], (require) ->

  BinaryUtils             = require 'kryptnostic.binary-utils'
  CredentialLoader        = require 'kryptnostic.credential-loader'
  DefaultChunkingStrategy = require 'kryptnostic.chunking.strategy.default'
  Logger                  = require 'kryptnostic.logger'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'

  log = Logger.get('SearchKeySerializer')

  #
  # Number of utf16 characters per unencrypted key chunk.
  # Setting this too high will result in RSA-OAEP "message too long" errors.
  #
  UNENCRYPTED_BLOCK_LENGTH = 384

  #
  # Number of uint8 (bytes) per encrypted RSA-OAEP key chunk.
  # This is a factor of RSA key size.
  #
  ENCRYPTED_PADDED_BLOCK_LENGTH = 1024

  validateEncryptedChunks = (chunks) ->
    chunks.forEach (chunk) ->
      unless chunk.length is ENCRYPTED_PADDED_BLOCK_LENGTH
        log.error('chunk failed validation', {
          length   : chunk.length,
          expected : ENCRYPTED_PADDED_BLOCK_LENGTH
        })
        throw new Error 'chunk validation error: wrong block size'

  btoa_safe = (str) ->
    return unescape(encodeURIComponent(str))

  atob_safe = (str) ->
    return decodeURIComponent(escape(str))

  #
  # Chunks and encrypts search keys for storage on the server.
  # Keys must be chunked due to message length limitations in RSA-OAEP.
  # Note that changing this class affects long-term serialized user private keys.
  #
  # Author: rbuckheit
  #
  class SearchKeySerializer

    constructor: ->
      @chunkingStrategy = new DefaultChunkingStrategy()
      @credentialLoader = new CredentialLoader()

    createRsaCryptoService : ->
      { keypair } = @credentialLoader.getCredentials()
      return new RsaCryptoService(keypair)

    # encrypt and chunk an unencrypted key. returns a uint8 array.
    # the array is chunked internally with fixed size of ENCRYPTED_PADDED_BLOCK_LENGTH.
    encrypt: (uint8) ->
      rsaCryptoService = @createRsaCryptoService()

      encryptedUint = _.chain(uint8)
        .thru((uint8) -> BinaryUtils.uint8ToUint16(uint8))
        .thru((uint16) -> BinaryUtils.uint16ToString(uint16))
        .thru((string) => @chunkingStrategy.split(string, UNENCRYPTED_BLOCK_LENGTH))
        .map((chunk) -> rsaCryptoService.encrypt(btoa_safe(chunk)))
        .map((chunk) -> BinaryUtils.stringToUint16(chunk))
        .map((chunk) -> BinaryUtils.uint16ToUint8(chunk))
        .tap((chunks) -> validateEncryptedChunks(chunks))
        .thru((chunks) -> BinaryUtils.joinUint(chunks))
        .value()

      return encryptedUint

    # decrypt and join a chunked stored key. returns a uint8 array of decrypted key.
    decrypt: (uint8) ->
      rsaCryptoService = @createRsaCryptoService()

      decryptedUint = _.chain(uint8)
        .thru((uint8) -> BinaryUtils.chunkUint(uint8, ENCRYPTED_PADDED_BLOCK_LENGTH))
        .tap((chunks) -> validateEncryptedChunks(chunks))
        .map((chunk) -> BinaryUtils.uint8ToUint16(chunk))
        .map((chunk) -> BinaryUtils.uint16ToString(chunk))
        .map((chunk) -> atob_safe(rsaCryptoService.decrypt(chunk)))
        .thru((chunks) => @chunkingStrategy.join(chunks))
        .thru((string) -> BinaryUtils.stringToUint16(string))
        .thru((uint16) -> BinaryUtils.uint16ToUint8(uint16))
        .value()

      return decryptedUint
