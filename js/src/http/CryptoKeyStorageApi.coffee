define 'kryptnostic.crypto-key-storage-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  # utils
  Configuration = require 'kryptnostic.configuration'
  Logger        = require 'kryptnostic.logger'
  Requests      = require 'kryptnostic.requests'

  rootKeysUrl            = -> Configuration.get('servicesUrl') + '/keys'
  clientHashUrl          = -> rootKeysUrl() + '/hash'
  fhePrivateKeyUrl       = -> rootKeysUrl() + '/private'
  fheSearchPrivateKeyUrl = -> rootKeysUrl() + '/searchprivate'

  logger = Logger.get('CryptoKeyStorageApi')

  #
  # HTTP calls for saving and retrieving user encryption keys.
  #
  class CryptoKeyStorageApi

    #
    # FHE private key
    #

    getFhePrivateKey: ->
      return Requests.getBlockCiphertextFromUrl(
        fhePrivateKeyUrl()
      )

    setFhePrivateKey: (key) ->
      Requests.postUint8ToUrl(
        fhePrivateKeyUrl(),
        key
      )
      .then (response) ->
        logger.info('setFhePrivateKey')

    #
    # search private key
    #

    getSearchPrivateKey: ->
      return Requests.getBlockCiphertextFromUrl( fheSearchPrivateKeyUrl() )

    setSearchPrivateKey: (key) ->
      Requests.postUint8ToUrl(
        fheSearchPrivateKeyUrl(),
        key
      )
      .then (response) ->
        logger.info('setSearchPrivateKey')

    #
    # client hash function
    #

    getClientHashFunction: ->
      return Requests.getByteArrayAsUint8Array(
        clientHashUrl()
      )

    setClientHashFunction: (clientHashFunction) ->
      Requests.postUint8ToUrl(
        clientHashUrl(),
        clientHashFunction
      )
      .then (response) ->
        logger.info('setClientHashFunction')

  return CryptoKeyStorageApi
