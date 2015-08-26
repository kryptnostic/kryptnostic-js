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

    setFhePrivateKey: (ciphertext) ->
      Promise.resolve()

    # search key
    # ==========

    getSearchPrivateKey: ->
      Promise.resolve()

    setSearchPrivateKey: (ciphertext) ->
      Promise.resolve()

    # client hash
    # ===========

    getClientHashFunction: ->
      Promise.resolve()

    setClientHashFunction: (ciphertext) ->
      Promise.resolve()

  return CryptoKeyStorageApi
