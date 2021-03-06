define 'kryptnostic.rsa-key-generator', [
  'require'
  'bluebird'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.kryptnostic-workers-api'
], (require) ->

  # libraries
  forge            = require 'forge'
  Promise          = require 'bluebird'

  # kryptnostic
  KryptnosticWorkersApi = require 'kryptnostic.kryptnostic-workers-api'

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('RsaKeyGenerator')

  RSA_KEY_SIZE     = 4096
  EXPONENT_NUM     = 0x10001
  EXPONENT_BIG_INT = new Uint8Array([1, 0, 1])

  class RsaKeyGenerator

    forgeGenerate: ->
      Promise.resolve()
      .then ->
        keypair            = {}
        forgeKeys          = forge.rsa.generateKeyPair(RSA_KEY_SIZE, EXPONENT_NUM)
        privateKeyAsn1     = forge.pki.privateKeyToAsn1(forgeKeys.privateKey)
        publicKeyAsn1      = forge.pki.publicKeyToAsn1(forgeKeys.publicKey)
        keypair.privateKey = forge.asn1.toDer(privateKeyAsn1)
        keypair.publicKey  = forge.asn1.toDer(publicKeyAsn1)
        return keypair

    webCryptoGenerate: ->
      Promise.resolve(
        window.crypto.subtle.generateKey(
          {
            name: 'RSA-OAEP',
            modulusLength: RSA_KEY_SIZE,
            publicExponent: EXPONENT_BIG_INT,
            hash: { name: 'SHA-256' }
          },
          true,
          ['encrypt', 'decrypt']
        )
      )
      .then (keys) ->
        # https://github.com/digitalbazaar/forge/issues/284#issuecomment-128388734
        p1 = window.crypto.subtle.exportKey('pkcs8', keys.privateKey)
          .then (exportedPrivateKey) ->
            privateKey = new forge.util.ByteBuffer(exportedPrivateKey)

        p2 = window.crypto.subtle.exportKey('spki', keys.publicKey)
          .then (exportedPublicKey) ->
            publicKey = new forge.util.ByteBuffer(exportedPublicKey)

        Promise.join(p1, p2, (privateKey, publicKey) ->
          keyPair            = {}
          keyPair.privateKey = privateKey
          keyPair.publicKey  = publicKey
          return keyPair
        )

    #
    # IE 11 Web Crypto
    # https://msdn.microsoft.com/en-us/library/dn904640(v=vs.85).aspx
    #
    ieWebCryptoGenerate: ->
      Promise.resolve()
      .then ->
        deferred = Promise.defer()
        keyOperation = window.msCrypto.subtle.generateKey(
          {
            name: 'RSA-OAEP',
            modulusLength: RSA_KEY_SIZE,
            publicExponent: EXPONENT_BIG_INT,
            hash: { name: 'SHA-256' }
          },
          true,
          ['encrypt', 'decrypt']
        )
        keyOperation.onerror = ->
          logger.error('Failed to generate RSA keys using IE web crypto')

        keyOperation.oncomplete = ->
          keyPair = keyOperation.result
          return deferred.resolve(keyPair)

        return deferred.promise

      .then (keys) ->
        deferred1 = Promise.defer()
        keyOpPrivate = window.msCrypto.subtle.exportKey('pkcs8', keys.privateKey)
        keyOpPrivate.onerror = ->
          logger.error('Failed to export RSA private key using IE web crypto')
        keyOpPrivate.oncomplete = ->
          privateKey = new forge.util.ByteBuffer(keyOpPrivate.result)
          return deferred1.resolve(privateKey)
        privateKeyPromise = deferred1.promise

        deferred2 = Promise.defer()
        keyOpPublic = window.msCrypto.subtle.exportKey('spki', keys.publicKey)
        keyOpPublic.onerror = ->
          logger.error('Failed to export RSA public key using IE web crypto')
        keyOpPublic.oncomplete = ->
          publicKey = new forge.util.ByteBuffer(keyOpPublic.result)
          return deferred2.resolve(publicKey)
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

      #
      # we treat Web Cryto in a browser that supports msCrypto (such as IE) as a special case. since msCrypto is not
      # available in a Web Worker, we don't want to geneate RSA keys in a Web Worker if msCrypto is available since
      # running msCrypto on the main thread will likely be faster than running Forge in a Web Worker.
      #
      if window.msCrypto?.subtle?
        KryptnosticWorkersApi.terminateWebWorker(KryptnosticWorkersApi.RSA_KEYS_GEN_WORKER)
        return @ieWebCryptoGenerate()

      else
        Promise.resolve()
        .then ->
          Promise.resolve(
            KryptnosticWorkersApi.queryWebWorker(KryptnosticWorkersApi.RSA_KEYS_GEN_WORKER)
          )
          .catch (e) -> return null
        .then (rsaKeyPair) =>

          KryptnosticWorkersApi.terminateWebWorker(KryptnosticWorkersApi.RSA_KEYS_GEN_WORKER)

          if rsaKeyPair?
            return rsaKeyPair

          if window.crypto?.subtle?
            return @webCryptoGenerate()
          else
            return @forgeGenerate()

  return RsaKeyGenerator
