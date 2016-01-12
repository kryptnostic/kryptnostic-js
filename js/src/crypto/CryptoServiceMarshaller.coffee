define 'kryptnostic.crypto-service-marshaller', [
  'require',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.binary-utils',
  'kryptnostic.deflating-marshaller'
], (require) ->

  AesCryptoService    = require 'kryptnostic.aes-crypto-service'
  BinaryUtils         = require 'kryptnostic.binary-utils'
  DeflatingMarshaller = require 'kryptnostic.deflating-marshaller'

  # WebCrypto API
  webCryptoApi = null
  if window.crypto?.subtle? or window.msCrypto?.subtle?
    webCryptoApi = window.crypto or window.msCrypto

  class CryptoServiceMarshaller

    constructor: ->
      @deflatingMarshaller = new DeflatingMarshaller()

    marshall: (cryptoService) ->
      { key, cypher } = cryptoService

      if cryptoService.constructor.name isnt 'AesCryptoService'
        throw new Error 'serialization only implemented for AesCryptoService'
      if !key
        throw new Error 'key cannot be blank'
      if !cypher
        throw new Error 'cypher cannot be blank'

      Promise.resolve()
      .then ->
        if webCryptoApi
          return webCryptoApi.subtle.exportKey(
            'raw',
            key
          )
          .then (rawKeyAsArrayBuffer) =>
            rawKeyAsUint8Array = new Uint8Array(rawKeyAsArrayBuffer)
            return BinaryUtils.uint8ToBase64(rawKeyAsUint8Array)
        else
          return btoa(key)
      .then (rawKey) =>
        rawCryptoService = {
          cypher,
          key: rawKey
        }
        serializedCryptoService = JSON.stringify(rawCryptoService)
        return @deflatingMarshaller.marshall(serializedCryptoService)

    unmarshall: (deflatedCryptoService) ->

      inflatedCryptoService     = @deflatingMarshaller.unmarshall(deflatedCryptoService)
      decompressedCryptoService = JSON.parse(inflatedCryptoService)

      Promise.resolve()
      .then ->
        key = atob(decompressedCryptoService.key)
        if webCryptoApi
          keyAsUint8Array = BinaryUtils.stringToUint8(key)
          return Promise.resolve(
            webCryptoApi.subtle.importKey(
              'raw',
              keyAsUint8Array,
              { name: decompressedCryptoService.cypher.algorithm },
              true,
              ['encrypt', 'decrypt']
            )
          )
        else
          return key
      .then (key) ->
        objectCryptoService = new AesCryptoService(
          decompressedCryptoService.cypher,
          key
        )
        return objectCryptoService


  return CryptoServiceMarshaller
