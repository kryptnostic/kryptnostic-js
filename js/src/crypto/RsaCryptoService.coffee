define 'kryptnostic.rsa-crypto-service', [
  'require',
  'forge',
  'lodash'
], (require) ->
  'use strict'

  _      = require 'lodash'
  Forge  = require 'forge'

  #
  # Author: nickdhewitt, rbuckheit
  #
  class RsaCryptoService

    # construct from forge public and private key objects
    constructor: ({ @privateKey, @publicKey }) ->
      if _.isEmpty(@privateKey)
        throw new Error 'empty private key'
      if _.isEmpty(@publicKey)
        throw new Error 'empty public key'

    encrypt: (plaintext) ->
      ciphertext = @publicKey.encrypt(plaintext, 'RSA-OAEP', {
        md : Forge.md.sha1.create()
      })
      return ciphertext

    decrypt: (ciphertext) ->
      plaintext = @privateKey.decrypt(ciphertext, 'RSA-OAEP', {
        md : Forge.md.sha1.create()
      })
      return plaintext

  return RsaCryptoService
