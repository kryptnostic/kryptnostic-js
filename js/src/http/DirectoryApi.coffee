define 'kryptnostic.directory-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.public-key-envelope'
  'kryptnostic.requests'
  'kryptnostic.block-ciphertext'
], (require) ->

  axios             = require 'axios'
  Requests          = require 'kryptnostic.requests'
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

  log             = Logger.get('DirectoryApi')


  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

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
      Promise.resolve()
      .then ->
        validateId(objectId)

        Promise.resolve(axios(Requests.wrapCredentials({
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

        Promise.resolve(axios(Requests.wrapCredentials({
          url     : cryptoServiceUrl() + '/' + objectId
          method  : 'POST'
          data    : JSON.stringify({ data: btoa(byteBufferStr) })
          headers : _.cloneDeep(DEFAULT_HEADERS)
        })))
      .then (response) ->
        log.info('setObjectCryptoService', { objectId })
        return response.data

    # gets encrypted RSA private keys for the current user
    getPrivateKey: ->
      Promise.resolve(axios(Requests.wrapCredentials({
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
        Promise.resolve(axios(Requests.wrapCredentials({
          url     : privateKeyUrl(),
          method  : 'PUT'
          data    : JSON.stringify(blockCiphertext)
          headers : _.cloneDeep(DEFAULT_HEADERS)
        })))
      .then (response) ->
        log.debug('setPrivateKey', { response })

    # uploads a user's public key.
    setPublicKey: (publicKeyEnvelope) ->
      Promise.resolve()
      .then ->
        publicKeyEnvelope.validate()
        Promise.resolve(axios(Requests.wrapCredentials({
          url     : publicKeyUrl()
          method  : 'PUT'
          data    : JSON.stringify(publicKeyEnvelope)
          headers : _.cloneDeep(DEFAULT_HEADERS)
        })))
      .then (response) ->
        log.debug('setPublicKey', { response })

    # gets the public key of a user in the same realm as the caller.
    getPublicKey: (uuid) ->
      Promise.resolve(axios(Requests.wrapCredentials({
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

    # sets the encrypted salt for a new user account.
    # manually sets principal and credential headers since user has not auth'ed yet.
    setSalt: ({ uuid, blockCiphertext, credential }) ->
      Promise.resolve()
      .then ->
        blockCiphertext.validate()
      .then ->
        principal = uuid
        request    = {
          url     : saltUrl()
          method  : 'PUT'
          headers : _.cloneDeep(DEFAULT_HEADERS)
          data    : JSON.stringify(blockCiphertext)
        }
        wrappedRequest = Requests.wrapCredentials(request, { principal, credential })
        axios(wrappedRequest)


    # gets users in the specified realm.
    # does not include uninitialized users who have not set their primary key yet.
    getUsers: ({ realm }) ->
      Promise.resolve(axios(Requests.wrapCredentials({
        url    : usersInRealmUrl() + '/' + realm
        method : 'GET'
      })))
      .then (response) =>
        uuids = response.data
        log.info('getUsers', uuids)
        return Promise.filter(uuids, (uuid) => @getPublicKey(uuid))

  return DirectoryApi
