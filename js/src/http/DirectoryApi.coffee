define 'soteria.directory-api', [
  'require'
  'jquery'
  'forge'
  'soteria.security-utils'
  'soteria.public-key-envelope'
  'soteria.logger'
], (require) ->

  jquery             = require 'jquery'
  SecurityUtils      = require 'soteria.security-utils'
  Logger             = require 'soteria.logger'
  PublicKeyEnvelope  = require 'soteria.public-key-envelope'
  Forge              = require 'forge'

  CRYPTO_SERVICE_URL = 'http://localhost:8081/v1/directory/object'
  PRIVATE_KEY_URL    = 'http://localhost:8081/v1/directory/private'
  PUBLIC_KEY_URL     = 'http://localhost:8081/v1/directory/public'

  logger             = Logger.get('DirectoryApi')

  validateId = (id) ->
    unless !!id
      throw new Error('cannot request or upload crypto service without an id!')

  validateCrytpoServiceByteBuffer = (byteBufferStr) ->
    if not _.isString(byteBufferStr) or _.isEmpty(byteBufferStr)
      throw new Error('cryptoservice byte buffer cannot be empty or non-string')

  #
  # HTTP calls for the /directory endpoint of Kryptnostic services.
  # Author: rbuckheit
  #
  class DirectoryApi

    # returns a serialized cryptoservice for the requested object
    getObjectCryptoService: (objectId) ->
      validateId(objectId)

      return jquery.ajax(SecurityUtils.wrapRequest({
        url  : CRYPTO_SERVICE_URL + '/' + objectId
        type : 'GET'
      }))
      .then (response) ->
        logger.info('getCryptoService', {objectId, response})
        serializedCryptoService = response.data
        return serializedCryptoService

    # stores a serialized cryptoservice for the requested object
    setObjectCryptoService: (objectId, byteBufferStr) ->
      validateId(objectId)
      validateCrytpoServiceByteBuffer(byteBufferStr)

      return jquery.ajax(SecurityUtils.wrapRequest({
        url         : CRYPTO_SERVICE_URL + '/' + objectId
        type        : 'POST'
        data        : JSON.stringify({data: btoa(byteBufferStr)})
        contentType : 'application/json'
      }))
      .then (response) ->
        logger.info('setObjectCryptoService', {response})
        return response

    # gets encrypted RSA private keys for the current user
    getRsaKeys: ->
      return jquery.ajax(SecurityUtils.wrapRequest({
        url  : PRIVATE_KEY_URL
        type : 'GET'
      }))
      .then (response) ->
        logger.debug('getRsaKeys', {response})
        return response

    # gets the public key of a user in the same realm as the caller.
    getPublicKey: (username) ->
      return jquery.ajax(SecurityUtils.wrapRequest({
        url  : PUBLIC_KEY_URL + '/' + username
        type : 'GET'
      }))
      .then (response) ->
        logger.debug('getPublicKey', {response})
        return new PublicKeyEnvelope(response)

  return DirectoryApi
