define 'soteria.keypair-serializer', [
  'require'
  'forge'
  'soteria.logger'
], (require) ->

  Forge  = require 'forge'
  Logger = require 'soteria.logger'

  log = Logger.get('KeypairSerializer')

  isUndefined = (serialized) ->
    return serialized is 'undefined'

  #
  # Serializes and rehydrates Forge keypairs.
  # Author: rbuckheit
  #
  class KeypairSerializer

    @serialize : (keypair) ->
      if !keypair || !keypair.privateKey
        throw new Error 'cannot serialize empty keypair'

      privateKeyAsn1   = Forge.pki.privateKeyToAsn1(keypair.privateKey)
      privateKeyBuffer = Forge.asn1.toDer(privateKeyAsn1)
      privateKeyBase64 = btoa(privateKeyBuffer.data)
      return privateKeyBase64

    @hydrate : (serialized) ->
      if !serialized || isUndefined(serialized)
        log.warn('keypair not initialized')
        return undefined

      privateKeyBuffer = atob(serialized)
      privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
      privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
      publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)
      return { privateKey , publicKey }

  return KeypairSerializer
