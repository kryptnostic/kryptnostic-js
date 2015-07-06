define 'soteria.rsa-compressing-encryption-service', [
  'require'
  'forge'
  'soteria.crypto-algorithm'
], (require) ->

  CryptoAlgorithm = require 'soteria.crypto-algorithm'
  Forge           = require 'forge'

  #
  # Public-key based encrypting service used to encrypt other keys.
  # Data is compressed prior to encryption because OAEP supports a limited number of bytes.
  #
  # Author: rbuckheit
  #

  class RsaCompressingEncryptionService

    constructor: (@cypher, @publicKey) ->
      unless @cypher is CryptoAlgorithm.RSA
        throw new Error 'Only RSA is supported for this service.'

    encrypt: (plaintext) ->
      # TODO deflate
      ciphertext = @publicKey.encrypt(plaintext, 'RSA-OAEP', {
        md : Forge.md.sha1.create()
      })
      return ciphertext
