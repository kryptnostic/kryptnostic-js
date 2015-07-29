define 'kryptnostic.public-key-envelope', [
  'require'
  'forge'
  'kryptnostic.logger'
], (require) ->

  Forge  = require 'forge'
  Logger = require 'kryptnostic.logger'

  log = Logger.get('PublicKeyEnvelope')

  #
  # Wrapper for a public key HTTP response, which can convert raw binary
  # keys into a Forge public key object.
  #
  # Author: rbuckheit
  #
  class PublicKeyEnvelope

    @createFromBuffer : (publicKeyBuffer) ->
      publicKey = btoa(publicKeyBuffer)
      return new PublicKeyEnvelope({ publicKey })

    # construct from a base 64 public key
    constructor: ({@publicKey}) ->
      @validate()

    validate: ->
      if !@publicKey
        throw new Error 'no public key defined!'

    toRsaPublicKey: ->
      publicKey       = atob(@publicKey)
      publicKeyBuffer = Forge.util.createBuffer(publicKey, 'raw')
      publicKeyAsn1   = Forge.asn1.fromDer(publicKeyBuffer)
      publicKey       = Forge.pki.publicKeyFromAsn1(publicKeyAsn1)
      return publicKey

  return PublicKeyEnvelope
