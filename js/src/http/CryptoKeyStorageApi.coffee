define 'kryptnostic.crypto-key-storage-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  Requests      = require 'kryptnostic.requests'
  Logger        = require 'kryptnostic.logger'
  Configuration = require 'kryptnostic.configuration'

  rootKeysUrl            = -> Configuration.get('servicesUrl') + '/keys'
  clientHashUrl          = -> rootKeysUrl() + '/hash'
  fhePrivateKeyUrl       = -> rootKeysUrl() + '/private'
  fheSearchPrivateKeyUrl = -> rootKeysUrl() + '/searchprivate'

  log = Logger.get('CryptoKeyStorageApi')

  #
  # HTTP calls for saving and retrieving user encryption keys.
  # Author: rbuckheit
  #
  class CryptoKeyStorageApi

    # rsa public key
    # ==========
    #   For future use

    # getRsaPublicKey: ->
    #   return Requests.getAsUint8FromUrl(rsaPublicKeyUrl())

    # setRsaPublicKey: (key) ->
    #   return Requests.postUint8ToUrl(rsaPublicKeyUrl(), key)
    #   .then (response) ->
    #     log.info('setSearchPrivateKey')
    #     return response.data

    # fhe key
    # =======

    getFhePrivateKey: ->
      return Requests.getAsUint8FromUrl( fhePrivateKeyUrl() )

    setFhePrivateKey: (key) ->
      Requests.postUint8ToUrl(fhePrivateKeyUrl(), key)
      .then (response) ->
        log.info('setFhePrivateKey')

    # search key
    # ==========

    getSearchPrivateKey: ->
      return Requests.getAsUint8FromUrl( fheSearchPrivateKeyUrl() )

    setSearchPrivateKey: (key) ->
      Requests.postUint8ToUrl(fheSearchPrivateKeyUrl(), key)
      .then (response) ->
        log.info('setSearchPrivateKey')


    # client hash
    # ===========

    getClientHashFunction: ->
      return Requests.getAsUint8FromUrl( clientHashUrl() )

    setClientHashFunction: (key) ->
      Requests.postUint8ToUrl(clientHashUrl(), key)
      .then (response) ->
        log.info('uploadSharingPair')

  return CryptoKeyStorageApi
