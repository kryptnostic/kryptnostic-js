define 'kryptnostic.rsa-key-generator', [
  'require'
  'forge'
  'kryptnostic.logger'
  'bluebird'
], (require) ->

  Forge        = require 'forge'
  Logger       = require 'kryptnostic.logger'
  Promise      = require 'bluebird'
  
  log          = Logger.get('RsaKeyGenerator')
  
  RSA_KEY_SIZE = 4096
  EXPONENT     = 0x10001

  class RsaKeyGenerator

    
    generate: (params) ->
      if window.crypto?.subtle?
        return @webCryptoGenerate(params)
      else if window.msCrypto?.subtle?
        return @ieWebCryptoGenerate(params)
      else
        return @forgeGenerate(params)

    forgeGenerate: (params) ->
      Promise.resolve()
      .then ->
        keypair            = {}
        forgeKeys          = Forge.rsa.generateKeyPair(params)
        privateKeyAsn1     = Forge.pki.privateKeyToAsn1(forgeKeys.privateKey)
        publicKeyAsn1      = Forge.pki.publicKeyToAsn1(forgeKeys.publicKey)
        keypair.privateKey = Forge.asn1.toDer(privateKeyAsn1)
        keypair.publicKey  = Forge.asn1.toDer(publicKeyAsn1)
        return keypair


    webCryptoGenerate: (params) ->
      Promise.resolve()
      .then ->
        window.crypto.subtle.generateKey( {
          name: 'RSA-OAEP'
          modulusLength: params.bits
          publicExponent: new Uint8Array([1, 0, 1]) # constants
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
          keyPair            = {}
          keyPair.privateKey = privateKey
          keyPair.publicKey  = publicKey
          return keyPair
        )

    # IE 11 Web Crypto
    ieWebCryptoGenerate: (params) ->
      Promise.resolve()
      .then ->
        deferred = Promise.defer()
        keyOperation = window.msCrypto.subtle.generateKey( {
          name: 'RSA-OAEP'
          modulusLength: params.bits
          publicExponent: new Uint8Array([1, 0, 1])
          hash: { name: 'SHA-256' }
        }, true, ['encrypt', 'decrypt'])
        keyOperation.onerror = ->
          log.error('sad failure')

        keyOperation.oncomplete = ->
          keyPair = keyOperation.result
          log.error(keyPair)
          return deferred.resolve(keyPair)
        
        return deferred.promise

      .then (keys) ->
        deferred1 = Promise.defer()
        keyOpPrivate = window.msCrypto.subtle.exportKey('pkcs8', keys.privateKey)
        keyOpPrivate.oncomplete = ->
          return deferred1.resolve(Forge.util.createBuffer(keyOpPrivate.result))
        privateKeyPromise = deferred1.promise

        deferred2 = Promise.defer()
        keyOpPublic = window.msCrypto.subtle.exportKey('spki', keys.publicKey)
        keyOpPublic.oncomplete = ->
          return deferred2.resolve(Forge.util.createBuffer(keyOpPublic.result))
        publicKeyPromise = deferred2.promise
        Promise.join(privateKeyPromise, publicKeyPromise, (privateKey, publicKey) ->
          keyPair            = {}
          keyPair.privateKey = privateKey
          keyPair.publicKey  = publicKey
          return keyPair
        )
     
    

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
      binary    = new Uint8Array(hexString.length)
      for i in [0..hexString.length]
        binary[i] = hexString[i]
      uLength     = Math.ceil(binary.length / 8)
      unsignedInt = new Uint8Array(uLength)
      for i in [0..uLength]
        uint8          = binary.subarray(i * 8, i * 8 + 7)
        # Note: this shit is broken. Should probably hard-code constants.
        unsignedInt[i] = parseInt(uint8, 2)
      return unsignedInt

  return RsaKeyGenerator
