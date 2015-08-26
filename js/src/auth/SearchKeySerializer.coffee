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

  BLOCK_LENGTH_IN_BYTES = 384

  #
  # Chunks and encrypts search keys for storage on the server.
  # Keys must be chunked due to message length limitations in RSA-OAEP.
  #
  # Author: rbuckheit
  #
  class SearchKeySerializer

    constructor: ->
      @chunkingStrategy = new DefaultChunkingStrategy()
      @credentialLoader = new CredentialLoader()

    getRsaCryptoService : ->
      { keypair } = @credentialLoader.getCredentials()
      return new RsaCryptoService(keypair)

    # encrypt and chunk an unencrypted key. return a list of string chunks.
    encrypt: (uint8) ->
      rsaCryptoService      = @getRsaCryptoService()
      stringKey             = BinaryUtils.uint8ToString(uint8)
      chunks                = @chunkingStrategy.split(stringKey, BLOCK_LENGTH_IN_BYTES)

      base64EncryptedChunks = _.chain(chunks)
        .map((chunk) -> rsaCryptoService.encrypt(chunk))
        .map((chunk) -> btoa(chunk))
        .value()

      return base64EncryptedChunks

    # decrypt and join a chunked stored key. return a string of key bytes
    decrypt: (base64EncryptedChunks) ->
      log.error('decrypt', base64EncryptedChunks)
      rsaCryptoService = @getRsaCryptoService()

      chunks = _.chain(base64EncryptedChunks)
        .map((chunk) -> atob(chunk))
        .map((chunk) -> rsaCryptoService.decrypt(chunk))
        .value()

      stringKey = @chunkingStrategy.join(chunks)

      return stringKey
