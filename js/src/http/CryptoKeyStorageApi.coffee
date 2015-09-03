define 'kryptnostic.crypto-key-storage-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
], (require) ->

  Promise = require 'bluebird'
  Logger  = require 'kryptnostic.logger'

  log = Logger.get('CryptoKeyStorageApi')

  #
  # HTTP calls for saving and retrieving user encryption keys.
  # Author: rbuckheit
  #
  class CryptoKeyStorageApi

    # fhe key
    # =======

    getFhePrivateKey: ->
      log.warn('CryptoKeyStorageApi not implemented!')
      return Promise.resolve()

    setFhePrivateKey: (key) ->
      log.warn('CryptoKeyStorageApi not implemented!')
      return Promise.resolve()

    # search key
    # ==========

    getSearchPrivateKey: ->
      log.warn('CryptoKeyStorageApi not implemented!')
      return Promise.resolve()

    setSearchPrivateKey: (key) ->
      log.warn('CryptoKeyStorageApi not implemented!')
      return Promise.resolve()

    # client hash
    # ===========

    getClientHashFunction: ->
      log.warn('CryptoKeyStorageApi not implemented!')
      return Promise.resolve()

    setClientHashFunction: (key) ->
      log.warn('CryptoKeyStorageApi not implemented!')
      return Promise.resolve()

  return CryptoKeyStorageApi
