define 'kryptnostic.share-processing-service', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.deflating-marshaller'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.encrypted-search-object-key'
], (require) ->

  Logger                   = require 'kryptnostic.logger'
  CryptoServiceLoader      = require 'kryptnostic.crypto-service-loader'
  DeflatingMarshaller      = require 'kryptnostic.deflating-marshaller'
  EncryptedSearchObjectKey = require 'kryptnostic.encrypted-search-object-key'

  log = Logger.get('ShareProcessingService')

  #
  # Processes incoming shares.
  # Author: rbuckheit
  #

  class ShareProcessingService

    constructor: ->
      @cryptoServiceLoader = new CryptoServiceLoader()
      @marshaller          = new DeflatingMarshaller()

    # processes all incoming shares, registering bridge keys for each.
    processShares: (shares) ->
      Promise.resolve()
      .then =>
        Promise.all(shares.map( (share) => @processShare(share) ))
      .then (encryptedSearchObjectKeys) =>
        @sharingClient.registerSearchKeys(searchObjectKeys)

    # downloads encrypted document key, decrypts it, and generates a new bridge key.
    # this key will be registered with the server.
    processShare: (share) ->
      Promise.resolve()
      .then =>
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss : false })
      .then (cryptoService) =>
        { id } = share

        blockCiphertext = share.sharingKey
        marshalled      = cryptoService.decrypt(blockCiphertext)
        sharingKey      = @marshaller.unmarshall(marshalled)

        bridgeKey = @fheEngine.getBridgeKey({ sharingKey })
        return new EncryptedSearchObjectKey { id, key : bridgeKey }
