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

    getFhePrivateKey: ->
      Promise.resolve()

    setFhePrivateKey: ->
      Promise.resolve()

  return CryptoKeyStorageApi
