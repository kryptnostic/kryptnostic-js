define 'kryptnostic.rsa-crypto-service', [
  'require',
  'forge',
  'lodash'
], (require) ->
  'use strict'

  _      = require 'lodash'
  Forge  = require 'forge'

  class RsaCryptoService

    #
    # HACK!!! - uglfifying changes constructor.name, so we can't rely on the name property
    #
    _CLASS_NAME: 'RsaCryptoService'
    @_CLASS_NAME: 'RsaCryptoService'

    # construct from forge public and private key objects
    constructor: ({ @privateKey, @publicKey }) ->
      if _.isEmpty(@privateKey) and _.isEmpty(@publicKey)
        throw new Error 'no public key or private key provided'

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
