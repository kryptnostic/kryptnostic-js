define 'soteria.directory-api', [
  'require'
  'jquery'
  'bluebird'
  'soteria.configuration'
  'soteria.logger'
  'soteria.public-key-envelope'
  'soteria.security-utils'
  'soteria.block-ciphertext'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'soteria.security-utils'
  Logger            = require 'soteria.logger'
  PublicKeyEnvelope = require 'soteria.public-key-envelope'
  Configuration     = require 'soteria.configuration'
  BlockCiphertext   = require 'soteria.block-ciphertext'
  Promise           = require 'bluebird'

  cryptoServiceUrl   = -> Configuration.get('servicesUrl') + '/directory/object'
  privateKeyUrl      = -> Configuration.get('servicesUrl') + '/directory/private'
  publicKeyUrl       = -> Configuration.get('servicesUrl') + '/directory/public'
  saltUrl            = -> Configuration.get('servicesUrl') + '/directory/salt'

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

      return Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : cryptoServiceUrl() + '/' + objectId
        type : 'GET'
      })))
      .then (response) ->
        logger.info('getCryptoService', {objectId, response})
        serializedCryptoService = response.data
        return serializedCryptoService

    # stores a serialized cryptoservice for the requested object
    setObjectCryptoService: (objectId, byteBufferStr) ->
      validateId(objectId)
      validateCrytpoServiceByteBuffer(byteBufferStr)

      return Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : cryptoServiceUrl() + '/' + objectId
        type        : 'POST'
        data        : JSON.stringify({data: btoa(byteBufferStr)})
        contentType : 'application/json'
      })))
      .then (response) ->
        logger.info('setObjectCryptoService', {response})
        return response

    # gets encrypted RSA private keys for the current user
    getRsaKeys: ->
      return Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : privateKeyUrl()
        type : 'GET'
      })))
      .then (response) ->
        logger.debug('getRsaKeys', {response})
        return new BlockCiphertext(response)

    # gets the public key of a user in the same realm as the caller.
    getPublicKey: (username) ->
      return Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : publicKeyUrl() + '/' + username
        type : 'GET'
      })))
      .then (response) ->
        logger.debug('getPublicKey', {response})
        return new PublicKeyEnvelope(response)

    # gets the user's encrypted salt.
    # request is not wrapped because the user has not auth'ed yet.
    getSalt: ({username, realm}) ->
      return Promise.resolve(jquery.ajax({
        url  : saltUrl() + '/' + realm + '/' + username,
        type : 'GET'
      }))
      .then (response) ->
        logger.info('getSalt', {response})
        return new BlockCiphertext(response)

  return DirectoryApi
