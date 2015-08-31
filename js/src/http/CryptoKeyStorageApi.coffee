define 'kryptnostic.crypto-key-storage-api', [
  'require'
  'bluebird'
], (require) ->

  Promise = require 'bluebird'

  #
  # HTTP calls for saving and retrieving user encryption keys.
  # Author: rbuckheit
  #
  class CryptoKeyStorageApi

    # fhe key
    # =======

    getFhePrivateKey: ->
      Promise.resolve()

    setFhePrivateKey: (key) ->
      Promise.resolve()

    # search key
    # ==========

    getSearchPrivateKey: ->
      Promise.resolve()

    setSearchPrivateKey: (key) ->
      Promise.resolve()

    # client hash
    # ===========

    getClientHashFunction: ->
      Promise.resolve()

    setClientHashFunction: (key) ->
      Promise.resolve()

  return CryptoKeyStorageApi
