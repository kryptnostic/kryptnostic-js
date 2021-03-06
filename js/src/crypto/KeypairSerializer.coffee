define 'kryptnostic.keypair-serializer', [
  'require'
  'forge'
  'kryptnostic.logger'
], (require) ->

  Forge  = require 'forge'
  Logger = require 'kryptnostic.logger'

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
      serialized       = btoa(privateKeyBuffer.data)
      return serialized

    @hydrate : (serialized) ->
      if !serialized || isUndefined(serialized)
        log.info('keypair not initialized')
        return undefined

      privateKeyBuffer = Forge.util.createBuffer(atob(serialized), 'raw')
      privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
      privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
      publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)
      return { privateKey , publicKey }

  return KeypairSerializer
