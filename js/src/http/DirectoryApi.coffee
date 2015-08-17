define 'kryptnostic.directory-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.public-key-envelope'
  'kryptnostic.security-utils'
  'kryptnostic.block-ciphertext'
  'kryptnostic.validators'
], (require) ->

  axios             = require 'axios'
  SecurityUtils     = require 'kryptnostic.security-utils'
  Logger            = require 'kryptnostic.logger'
  PublicKeyEnvelope = require 'kryptnostic.public-key-envelope'
  Configuration     = require 'kryptnostic.configuration'
  BlockCiphertext   = require 'kryptnostic.block-ciphertext'
  Promise           = require 'bluebird'
  validators        = require 'kryptnostic.validators'

  { validateId }    = validators

  cryptoServiceUrl   = -> Configuration.get('servicesUrl') + '/directory/object'
  privateKeyUrl      = -> Configuration.get('servicesUrl') + '/directory/private'
  publicKeyUrl       = -> Configuration.get('servicesUrl') + '/directory/public'
  saltUrl            = -> Configuration.get('servicesUrl') + '/directory/salt'
  usersInRealmUrl    = -> Configuration.get('servicesUrl') + '/directory'

  log             = Logger.get('DirectoryApi')


  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

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
      Promise.resolve()
      .then ->
        validateId(objectId)

        Promise.resolve(axios(SecurityUtils.wrapRequest({
          url    : cryptoServiceUrl() + '/' + objectId
          method : 'GET'
        })))
      .then (response) ->
        serializedCryptoService = response.data.data
        log.info('getObjectCryptoService', { objectId })
        return serializedCryptoService

    # stores a serialized cryptoservice for the requested object
    setObjectCryptoService: (objectId, byteBufferStr) ->
      Promise.resolve()
      .then ->
        validateId(objectId)
        validateCrytpoServiceByteBuffer(byteBufferStr)

        Promise.resolve(axios(SecurityUtils.wrapRequest({
          url     : cryptoServiceUrl() + '/' + objectId
          method  : 'POST'
          data    : JSON.stringify({ data: btoa(byteBufferStr) })
          headers : _.clone(DEFAULT_HEADER)
        })))
      .then (response) ->
        log.info('setObjectCryptoService', { objectId })
        return response.data

    # gets encrypted RSA private keys for the current user
    getPrivateKey: ->
      Promise.resolve(axios(SecurityUtils.wrapRequest({
        url    : privateKeyUrl()
        method : 'GET'
      })))
      .then (response) ->
        ciphertext = response.data
        if _.isEmpty(ciphertext)
          log.warn('getPrivateKey - no key available')
          return undefined
        else
          return new BlockCiphertext(ciphertext)

    # uploads a password-encrypted private key.
    setPrivateKey: (blockCiphertext) ->
      Promise.resolve()
      .then ->
        blockCiphertext.validate()
        Promise.resolve(axios(SecurityUtils.wrapRequest({
          url     : privateKeyUrl(),
          method  : 'PUT'
          data    : JSON.stringify(blockCiphertext)
          headers : _.clone(DEFAULT_HEADER)
        })))
      .then (response) ->
        log.debug('setPrivateKey', { response })

    # uploads a user's public key.
    setPublicKey: (publicKeyEnvelope) ->
      Promise.resolve()
      .then ->
        publicKeyEnvelope.validate()
        Promise.resolve(axios(SecurityUtils.wrapRequest({
          url     : publicKeyUrl()
          method  : 'PUT'
          data    : JSON.stringify(publicKeyEnvelope)
          headers : _.clone(DEFAULT_HEADER)
        })))
      .then (response) ->
        log.debug('setPublicKey', { response })

    # gets the public key of a user in the same realm as the caller.
    getPublicKey: (uuid) ->
      Promise.resolve(axios(SecurityUtils.wrapRequest({
        url    : publicKeyUrl() + '/' + uuid
        method : 'GET'
      })))
      .then (response) ->
        envelope = response.data
        log.debug('getPublicKey', { envelope })
        return new PublicKeyEnvelope(envelope)
      .catch (e) ->
        return undefined

    # gets the user's encrypted salt.
    # request is not wrapped because the user has not auth'ed yet.
    getSalt: (uuid) ->
      Promise.resolve(axios({
        url    : saltUrl() + '/' + uuid
        method : 'GET'
      }))
      .then (response) ->
        ciphertext = response.data
        log.info('ciphertext', ciphertext)
        if _.isEmpty(ciphertext)
          throw new Error 'incorrect credentials'
        else
          return new BlockCiphertext(ciphertext)

    # gets users in the specified realm.
    # does not include uninitialized users who have not set their primary key yet.
    getUsers: ({ realm }) ->
      Promise.resolve(axios(SecurityUtils.wrapRequest({
        url    : usersInRealmUrl() + '/' + realm
        method : 'GET'
      })))
      .then (response) =>
        uuids = response.data
        log.info('getUsers', uuids)
        return Promise.filter(uuids, (uuid) => @getPublicKey(uuid))

  return DirectoryApi
