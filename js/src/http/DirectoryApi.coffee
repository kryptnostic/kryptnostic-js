define 'kryptnostic.directory-api', [
  'require'
  'jquery'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.public-key-envelope'
  'kryptnostic.security-utils'
  'kryptnostic.block-ciphertext'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'kryptnostic.security-utils'
  Logger            = require 'kryptnostic.logger'
  PublicKeyEnvelope = require 'kryptnostic.public-key-envelope'
  Configuration     = require 'kryptnostic.configuration'
  BlockCiphertext   = require 'kryptnostic.block-ciphertext'
  Promise           = require 'bluebird'

  cryptoServiceUrl   = -> Configuration.get('servicesUrl') + '/directory/object'
  privateKeyUrl      = -> Configuration.get('servicesUrl') + '/directory/private'
  publicKeyUrl       = -> Configuration.get('servicesUrl') + '/directory/public'
  saltUrl            = -> Configuration.get('servicesUrl') + '/directory/salt'
  usersInRealmUrl    = -> Configuration.get('servicesUrl') + '/directory'

  logger             = Logger.get('DirectoryApi')

  APPLICATION_JSON_CONTENT_TYPE = 'application/json'

  validateId = (id) ->
    unless !!id
      throw new Error 'cannot request or upload crypto service without an id!'

  validateCrytpoServiceByteBuffer = (byteBufferStr) ->
    if not _.isString(byteBufferStr) or _.isEmpty(byteBufferStr)
      throw new Error 'cryptoservice byte buffer cannot be empty or non-string'

  #
  # HTTP calls for the /directory endpoint of Kryptnostic services.
  # Author: rbuckheit
  #
  class DirectoryApi

    # returns a serialized cryptoservice for the requested object
    getObjectCryptoService: (objectId) ->
      validateId(objectId)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : cryptoServiceUrl() + '/' + objectId
        type : 'GET'
      })))
      .then (response) ->
        logger.info('getCryptoService', { objectId, response })
        serializedCryptoService = response.data
        return serializedCryptoService

    # stores a serialized cryptoservice for the requested object
    setObjectCryptoService: (objectId, byteBufferStr) ->
      validateId(objectId)
      validateCrytpoServiceByteBuffer(byteBufferStr)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : cryptoServiceUrl() + '/' + objectId
        type        : 'POST'
        data        : JSON.stringify({ data: btoa(byteBufferStr) })
        contentType : APPLICATION_JSON_CONTENT_TYPE
      })))
      .then (response) ->
        logger.info('setObjectCryptoService', { response })
        return response

    # gets encrypted RSA private keys for the current user
    getPrivateKey: ->
      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : privateKeyUrl()
        type : 'GET'
      })))
      .then (response) ->
        if _.isEmpty(response)
          logger.warn('getPrivateKey - no key available')
          return undefined
        else
          logger.debug('getPrivateKey', { response })
          return new BlockCiphertext(response)

    # uploads a password-encrypted private key.
    setPrivateKey: (blockCiphertext) ->
      blockCiphertext.validate()

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : privateKeyUrl(),
        type        : 'PUT'
        data        : JSON.stringify(blockCiphertext)
        contentType : APPLICATION_JSON_CONTENT_TYPE
      })))
      .then (response) ->
        logger.debug('setPrivateKey', { response })

    # uploads a user's public key.
    setPublicKey: (publicKeyEnvelope) ->
      publicKeyEnvelope.validate()

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : publicKeyUrl()
        type        : 'PUT'
        data        : JSON.stringify(publicKeyEnvelope)
        contentType : APPLICATION_JSON_CONTENT_TYPE
      })))
      .then (response) ->
        logger.debug('setPublicKey', { response })

    # gets the public key of a user in the same realm as the caller.
    getPublicKey: (username) ->
      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : publicKeyUrl() + '/' + username
        type : 'GET'
      })))
      .then (response) ->
        logger.debug('getPublicKey', { response })
        return new PublicKeyEnvelope(response)

    # gets the user's encrypted salt.
    # request is not wrapped because the user has not auth'ed yet.
    getSalt: ({ username, realm }) ->
      Promise.resolve(jquery.ajax({
        url  : saltUrl() + '/' + realm + '/' + username,
        type : 'GET'
      }))
      .then (response) ->
        if _.isEmpty(response)
          throw new Error 'incorrect username or password'
        else
         return new BlockCiphertext(response)

    # gets users in the specified realm
    getUsers: ({ realm }) ->
      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : usersInRealmUrl() + '/' + realm
        type : 'GET'
      })))
      .then (users) ->
        logger.info('getUsers', users)
        return _.pluck(users, 'name')

  return DirectoryApi
