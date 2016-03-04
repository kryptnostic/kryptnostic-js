define 'kryptnostic.crypto-service-marshaller', [
  'require'
  'kryptnostic.deflating-marshaller'
  'kryptnostic.aes-crypto-service'
], (require) ->

  DeflatingMarshaller = require 'kryptnostic.deflating-marshaller'
  AesCryptoService    = require 'kryptnostic.aes-crypto-service'

  #
  # Service for serializing and marshalling CryptoServices using the DeflatingMarshaller.
  # Author: rbuckheit
  #
  class CryptoServiceMarshaller

    constructor: ->
      @deflatingMarshaller = new DeflatingMarshaller()

    marshall: (cryptoService) ->
      { key, cypher } = cryptoService

      if cryptoService._CLASS_NAME isnt AesCryptoService._CLASS_NAME
        throw new Error 'serialization only implemented for AesCryptoService'
      if !key
        throw new Error 'key cannot be blank'
      if !cypher
        throw new Error 'cypher cannot be blank'

      rawCryptoService        = { cypher, key: btoa(key) }
      serializedCryptoService = JSON.stringify(rawCryptoService)
      return @deflatingMarshaller.marshall(serializedCryptoService)

    unmarshall: (deflatedCryptoService) ->

      inflatedCryptoService     = @deflatingMarshaller.unmarshall(deflatedCryptoService)
      decompressedCryptoService = JSON.parse(inflatedCryptoService)

      objectCryptoService = new AesCryptoService(
        decompressedCryptoService.cypher,
        atob(decompressedCryptoService.key)
      )

      return objectCryptoService


  return CryptoServiceMarshaller
