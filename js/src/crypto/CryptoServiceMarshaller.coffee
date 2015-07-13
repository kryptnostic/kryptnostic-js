define 'soteria.crypto-service-marshaller', [
  'require'
  'soteria.deflating-marshaller'
  'soteria.aes-crypto-service'
], (require) ->

  DeflatingMarshaller = require 'soteria.deflating-marshaller'
  AesCryptoService    = require 'soteria.aes-crypto-service'

  #
  # Service for serializing and marshalling CryptoServices using the DeflatingMarshaller.
  # Author: rbuckheit
  #
  class CryptoServiceMarshaller

    constructor: ->
      @deflatingMarshaller = new DeflatingMarshaller()

    marshall: (cryptoService) ->
      {key, cypher} = cryptoService

      if cryptoService.constructor.name isnt 'AesCryptoService'
        throw new Error 'serialization only implemented for AesCryptoService'
      if !key
        throw new Error 'key cannot be blank'
      if !cypher
        throw new Error 'cypher cannot be blank'

      rawCryptoService        = {cypher, key: btoa(key)}
      serializedCryptoService = JSON.stringify(rawCryptoService)
      return @deflatingMarshaller.marshall(serializedCryptoService)

    unmarshall: (serializedCryptoService, rsaCryptoService) ->
      deflatedCryptoService     = rsaCryptoService.decrypt(atob(serializedCryptoService))
      inflatedCryptoService     = @deflatingMarshaller.unmarshall(deflatedCryptoService)
      decompressedCryptoService = JSON.parse(inflatedCryptoService)
      objectCryptoService       = new AesCryptoService(
        decompressedCryptoService.cypher,
        atob(decompressedCryptoService.key)
      )

      return objectCryptoService


  return CryptoServiceMarshaller
