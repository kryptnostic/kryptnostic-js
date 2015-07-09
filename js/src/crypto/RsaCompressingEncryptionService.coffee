define 'soteria.rsa-compressing-encryption-service', [
  'require'
  'forge'
  'soteria.crypto-algorithm'
  'soteria.deflating-marshaller'
], (require) ->

  Forge               = require 'forge'
  DeflatingMarshaller = require 'soteria.deflating-marshaller'

  #
  # Public-key based encrypting service used to encrypt other keys.
  # Data is compressed prior to encryption because OAEP supports a limited number of bytes.
  #
  # Author: rbuckheit
  #
  class RsaCompressingEncryptionService

    constructor: (@publicKey) ->
      @marshaller = new DeflatingMarshaller()

    encrypt: (data) ->
      deflated   = @marshaller.marshall(data)
      md         = Forge.md.sha1.create()
      ciphertext = @publicKey.encrypt(deflated, 'RSA-OAEP', { md })
      return ciphertext

  return RsaCompressingEncryptionService
