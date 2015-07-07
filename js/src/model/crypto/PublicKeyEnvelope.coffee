define 'soteria.public-key-envelope', [
  'require'
  'forge'
], (require) ->

  Forge = require 'forge'

  #
  # Wrapper for a public key HTTP response, which can convert raw binary
  # keys into a Forge public key object.
  #
  # Author: rbuckheit
  #
  class PublicKeyEnvelope

    # construct from raw json.
    constructor: ({@publicKey}) ->
      @publicKey = atob(@publicKey)
      @validate()

    validate: ->
      if !@publicKey
        throw new Error 'no public key defined!'

    toRsaPublicKey: ->

      publicKeyBuffer = Forge.util.createBuffer(@publicKey, 'raw')
      publicKeyAsn1   = Forge.asn1.fromDer(publicKeyBuffer)
      publicKey       = Forge.pki.publicKeyFromAsn1(publicKeyAsn1)
      return publicKey

  return PublicKeyEnvelope
