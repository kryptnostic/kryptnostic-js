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
      log.info("key length is #{uint8.length} bytes")
      rsaCryptoService      = @getRsaCryptoService()
      stringKey             = BinaryUtils.uint8ToString(uint8)
      chunks                = @chunkingStrategy.split(stringKey, BLOCK_LENGTH_IN_BYTES)
      encryptedChunks       = _.map(chunks, (chunk) -> rsaCryptoService.encrypt(chunk))
      base64EncryptedChunks = _.map(chunks, (chunk) -> btoa(chunk))
      log.info('generated new key', { chunks: base64EncryptedChunks.length })
      return base64EncryptedChunks

