define 'kryptnostic.rsa-key-generator', [
  'require'
  'forge'
  'kryptnostic.logger'
  'bluebird'
], (require) ->

  Forge            = require 'forge'
  Logger           = require 'kryptnostic.logger'
  Promise          = require 'bluebird'
  
  log              = Logger.get('RsaKeyGenerator')
  
  RSA_KEY_SIZE     = 4096
  EXPONENT_NUM     = 0x10001
  EXPONENT_BIG_INT = new Uint8Array([1, 0, 1])

  class RsaKeyGenerator

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
          publicExponent: params.e
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
          publicExponent: params.e
          hash: { name: 'SHA-256' }
        }, true, ['encrypt', 'decrypt'])
        keyOperation.onerror = ->
          log.error('Failed to generate RSA keys using IE web crypto')

        keyOperation.oncomplete = ->
          keyPair = keyOperation.result
          return deferred.resolve(keyPair)
        
        return deferred.promise

      .then (keys) ->
        deferred1 = Promise.defer()
        keyOpPrivate = window.msCrypto.subtle.exportKey('pkcs8', keys.privateKey)
        keyOpPrivate.onerror = ->
          log.error('Failed to export RSA private key using IE web crypto')
        keyOpPrivate.oncomplete = ->
          return deferred1.resolve(Forge.util.createBuffer(keyOpPrivate.result))
        privateKeyPromise = deferred1.promise

        deferred2 = Promise.defer()
        keyOpPublic = window.msCrypto.subtle.exportKey('spki', keys.publicKey)
        keyOpPublic.onerror = ->
          log.error('Failed to export RSA public key using IE web crypto')
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
      if window.crypto?.subtle?
        params = { bits: RSA_KEY_SIZE, e: EXPONENT_BIG_INT }
        log.info('generating keypair', params)
        log.debug('using web crypto API to generate keypair')
        return @webCryptoGenerate(params)
      else if window.msCrypto?.subtle?
        params = { bits: RSA_KEY_SIZE, e: EXPONENT_BIG_INT }
        log.info('generating keypair', params)
        log.debug('using IE 11 web crypto API to generate keypair')
        return @ieWebCryptoGenerate(params)
      else
        params = { bits: RSA_KEY_SIZE, e: EXPONENT_NUM }
        log.info('generating keypair', params)
        log.debug('using Forge to generate keypair')
        return @forgeGenerate(params)

  return RsaKeyGenerator
