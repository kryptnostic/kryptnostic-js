define 'kryptnostic.crypto-key-storage-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  Configuration = require 'kryptnostic.configuration'
  Logger        = require 'kryptnostic.logger'
  Requests      = require 'kryptnostic.requests'

  # constants
  CONTENT_TYPE_APPLICATION_JSON         = { 'Content-Type': 'application/json' }
  CONTENT_TYPE_APPLICATION_OCTET_STREAM = { 'Content-Type': 'application/octet-stream' }

  rootKeysUrl            = -> Configuration.get('servicesUrl') + '/keys'
  clientHashUrl          = -> rootKeysUrl() + '/hash'
  fhePrivateKeyUrl       = -> rootKeysUrl() + '/private'
  fheSearchPrivateKeyUrl = -> rootKeysUrl() + '/searchprivate'

  logger = Logger.get('CryptoKeyStorageApi')

  #
  # HTTP calls for saving and retrieving user encryption keys
  #
  class CryptoKeyStorageApi

    #
    # FHE private key
    #

    getFhePrivateKey: ->
      return Requests.getBlockCiphertextFromUrl(
        fhePrivateKeyUrl()
      )

    setFhePrivateKey: (fhePrivateKey) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : fhePrivateKeyUrl()
            data    : fhePrivateKey
            headers : CONTENT_TYPE_APPLICATION_JSON
          })
        )
      )
      .then (response) ->
        logger.info('setFhePrivateKey')

    #
    # search private key
    #

    getSearchPrivateKey: ->
      return Requests.getBlockCiphertextFromUrl(
        fheSearchPrivateKeyUrl()
      )

    setSearchPrivateKey: (fheSearchPrivateKey) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : fheSearchPrivateKeyUrl()
            data    : fheSearchPrivateKey
            headers : CONTENT_TYPE_APPLICATION_JSON
          })
        )
      )
      .then (response) ->
        logger.info('setSearchPrivateKey')

    #
    # client hash function
    #

    getClientHashFunction: ->
      return Requests.getAsUint8FromUrl(
        clientHashUrl()
      )

    setClientHashFunction: (clientHashFunction) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : clientHashUrl()
            data    : clientHashFunction
            headers : CONTENT_TYPE_APPLICATION_OCTET_STREAM
          })
        )
      )
      .then (response) ->
        logger.info('setClientHashFunction')

  return CryptoKeyStorageApi
