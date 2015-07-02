define 'soteria.directory-api', [
  'require'
  'jquery'
  'soteria.security-utils'
  'soteria.logger'
], (require) ->

  jquery             = require 'jquery'
  SecurityUtils      = require 'soteria.security-utils'
  Logger             = require 'soteria.logger'

  CRYPTO_SERVICE_URL = 'http://localhost:8081/v1/directory/object'
  PRIVATE_KEY_URL    = 'http://localhost:8081/v1/directory/private'

  {log, error}       = Logger.get('DirectoryApi')

  validateId = (id) ->
    unless !!id
      throw new Error('cannot request or upload crypto service without an id!')

  #
  # HTTP calls for loading and storing cryptoservices.
  # Author: rbuckheit
  #
  class DirectoryApi

    constructor: ->

    # returns a serialized cryptoservice for the requested object
    getObjectCryptoService: (objectId) ->
      validateId(objectId)

      return jquery.ajax(SecurityUtils.wrapRequest({
        url  : CRYPTO_SERVICE_URL + '/' + objectId
        type : 'GET'
      }))
      .then (response) ->
        log('getCryptoService', {objectId, response})
        serializedCryptoService = response.data
        return serializedCryptoService

    # stores a serialized cryptoservice for the requested object
    setObjectCryptoService: (objectId, cryptoService) ->
      validateId(object)

      error('setObjectCryptoService is not implemented!')

    # gets encrypted RSA private keys for the current user
    getRsaKeys : ->
      return jquery.ajax(SecurityUtils.wrapRequest({
        url  : PRIVATE_KEY_URL
        type : 'GET'
      }))
      .then (response) ->
        log('getRsaKeys', {response})
        return response

  return DirectoryApi
