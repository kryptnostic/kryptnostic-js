define 'kryptnostic.search-key-serializer', [
  'require'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.binary-utils'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.credential-loader'
  'kryptnostic.chunking.strategy.default'
], (require) ->

  forge                   = require 'forge'
  BinaryUtils             = require 'kryptnostic.binary-utils'
  CredentialLoader        = require 'kryptnostic.credential-loader'
  DefaultChunkingStrategy = require 'kryptnostic.chunking.strategy.default'
  Logger                  = require 'kryptnostic.logger'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'

  log = Logger.get('SearchKeySerializer')

  {
    chunkUint8
    cleanUint8Buffer
    joinUint8
    stringToUint16
    uint16ToString
    uint16ToUint8
    uint8ToUint16
  } = BinaryUtils

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

  #
  # Chunks and encrypts search keys for storage on the server.
  # Keys must be chunked due to message length limitations in RSA-OAEP.
  # Note that changing this class will likely break long-term serialized user private keys.
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
        .thru((uint8) -> cleanUint8Buffer(uint8))
        .thru((uint8) -> forge.util.binary.base64.encode(uint8))
        .thru((string) => @chunkingStrategy.split(string, UNENCRYPTED_BLOCK_LENGTH))
        .map((chunk) -> rsaCryptoService.encrypt(chunk))
        .map((chunk) -> stringToUint16(chunk))
        .map((chunk) -> uint16ToUint8(chunk))
        .tap((chunks) -> validateEncryptedChunks(chunks))
        .thru((chunks) -> joinUint8(chunks))
        .value()

      return encryptedUint

    # decrypt and join a chunked stored key. returns a uint8 array of decrypted key.
    decrypt: (uint8) ->
      rsaCryptoService = @createRsaCryptoService()

      decryptedUint = _.chain(uint8)
        .thru((uint8) -> chunkUint8(uint8, ENCRYPTED_PADDED_BLOCK_LENGTH))
        .tap((chunks) -> validateEncryptedChunks(chunks))
        .map((chunk) -> uint8ToUint16(chunk))
        .map((chunk) -> uint16ToString(chunk))
        .map((chunk) -> rsaCryptoService.decrypt(chunk))
        .thru((chunks) => @chunkingStrategy.join(chunks))
        .thru((string) -> forge.util.binary.base64.decode(string))
        .thru((uint8) -> cleanUint8Buffer(uint8))
        .value()

      return decryptedUint
