define 'kryptnostic.crypto-key-storage-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
], (require) ->

  Promise  = require 'bluebird'
  Requests = require 'kryptnostic.requests'
  Logger   = require 'kryptnostic.logger'

  rootKeysUrl   = -> Configuration.get('servicesUrl') + '/keys'
  privateKeyUrl = -> rootKeysUrl() + '/private'
  publicKeyUrl  = -> rootKeysUrl() + '/public'
  clientHashUrl = -> rootKeysUrl() + '/hash'

  log = Logger.get('CryptoKeyStorageApi')

  #
  # HTTP calls for saving and retrieving user encryption keys.
  # Author: rbuckheit
  #
  class CryptoKeyStorageApi

    # fhe key
    # =======

    getFhePrivateKey: ->
      return Requests.getAsBlobFromUrl(privateKeyUrl())

    setFhePrivateKey: (key) ->
      return Requests.postToUrl(privateKeyUrl(), key)
      .then (response) ->
        log.info('setFhePrivateKey')
        return response.data

    # search key
    # ==========

    getSearchPrivateKey: ->
      return Requests.getAsBlobFromUrl(publicKeyUrl())

    setSearchPrivateKey: (key) ->
      return Requests.postToUrl(publicKeyUrl(), key)
      .then (response) ->
        log.info('setSearchPrivateKey')
        return response.data


    # client hash
    # ===========

    getClientHashFunction: ->
      return Requests.getAsBlobFromUrl(clientHashUrl())

    setClientHashFunction: (key) ->
      return Requests.postToUrl(clientHashUrl(), key)
      .then (response) ->
        log.info('uploadSharingPair')
        return response.data

  return CryptoKeyStorageApi
