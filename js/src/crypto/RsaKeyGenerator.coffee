define 'kryptnostic.rsa-key-generator', [
  'require'
  'forge'
  'kryptnostic.logger'
  'bluebird'
], (require) ->

  Forge  = require 'forge'
  Logger = require 'kryptnostic.logger'
  Promise = require 'bluebird'

  log = Logger.get('RsaKeyGenerator')

  RSA_KEY_SIZE = 4096
  EXPONENT     = 0x10001

  class RsaKeyGenerator

    
    generate: (params) ->
      if window.crypto?.subtle?
        return @webCryptoGenerate(params)
      # else if
        # ie 11 web crypto
      # Forge crypto
      else
        keyPair = Forge.rsa.generateKeyPair(params)

    webCryptoGenerate: (params) ->
      Promise.resolve()
      .then =>
        window.crypto.subtle.generateKey( {
          name: 'RSA-OAEP'
          modulusLength: params.bits
          publicExponent: @numToUnsignedUint8Array(params.e)
          hash: { name: 'SHA-256' }
        }, true, ['encrypt', 'decrypt'])
      .then (keys) ->
        p1 = window.crypto.subtle.exportKey('pkcs8', keys.privateKey)
          .then (exported) ->
            privateKey = Forge.util.createBuffer(exported)
        p2 = window.crypto.subtle.exportKey('spki', keys.publicKey)
          .then (exported) ->
            publicKey = Forge.util.createBuffer(exported)
        Promise.join(p1, p2, (privateKey, publicKey) ->
          keyPair = {}
          keyPair.privateKey = privateKey
          keyPair.publicKey = publicKey
          return keyPair
        )

    # Forge
    # privateKeyAsn1       = Forge.pki.privateKeyToAsn1(keypair.privateKey)
    #     privateKeyBuffer     = Forge.asn1.toDer(privateKeyAsn1)
# publicKeyAsn1       = Forge.pki.publicKeyToAsn1(keypair.publicKey)
#         publicKeyBuffer     = Forge.asn1.toDer(publicKeyAsn1)

    # Generate public and private RSA keys
    # returns a Promise object with private and public keys in Forge buffer objects
    generateKeypair: ->
      params = { bits: RSA_KEY_SIZE, e: EXPONENT }
      log.info('generating keypair', params)
      return @generate(params)
    
    ##########
    ## Helpers
    ##########

    numToUnsignedUint8Array: (num) ->
      hexString = num.toString(2)
      array = new Uint8Array(hexString.length)
      for i in [0..hexString.length]
        array[i] = hexString[i]
      arr2size = Math.ceil(array.length/8)
      array2 = new Uint8Array(arr2size)
      for i in [0..arr2size]
        uint8 = array.slice(i*8, i*8 + 7)
        array2[i] = Number.parseInt(uint8, 2)
      return array2

  return RsaKeyGenerator
