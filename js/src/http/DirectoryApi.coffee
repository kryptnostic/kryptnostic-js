define 'kryptnostic.directory-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.public-key-envelope'
  'kryptnostic.requests'
  'kryptnostic.block-ciphertext'
  'kryptnostic.validators'
  'kryptnostic.caching-service'
], (require) ->

  axios             = require 'axios'
  Requests          = require 'kryptnostic.requests'
  Logger            = require 'kryptnostic.logger'
  PublicKeyEnvelope = require 'kryptnostic.public-key-envelope'
  Configuration     = require 'kryptnostic.configuration'
  BlockCiphertext   = require 'kryptnostic.block-ciphertext'
  Promise           = require 'bluebird'
  validators        = require 'kryptnostic.validators'
  Cache             = require 'kryptnostic.caching-service'

  { validateId }    = validators

  cryptoServiceUrl   = -> Configuration.get('servicesUrl') + '/directory/object'
  privateKeyUrl      = -> Configuration.get('servicesUrl') + '/directory/private'
  publicKeyUrl       = -> Configuration.get('servicesUrl') + '/directory/public'
  saltUrl            = -> Configuration.get('servicesUrl') + '/directory/salt'
  usersInRealmUrl    = -> Configuration.get('servicesUrl') + '/directory'

  log             = Logger.get('DirectoryApi')


  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

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
      cached = Cache.get( Cache.CRYPTO_SERVICES, objectId )
      if cached?
        return cached
      Promise.resolve()
      .then ->
        validateId(objectId)

        Promise.resolve(axios(Requests.wrapCredentials({
          url    : cryptoServiceUrl() + '/' + objectId
          method : 'GET'
        })))
      .then (response) ->
        serializedCryptoService = response.data.data
        if serializedCryptoService
          Cache.store( Cache.CRYPTO_SERVICES, objectId, serializedCryptoService )
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
      cached = Cache.get(Cache.PUBLIC_KEYS, uuid )
      if cached?
        return cached
      Promise.resolve(axios(Requests.wrapCredentials({
        url    : publicKeyUrl() + '/' + uuid
        method : 'GET'
      })))
      .then (response) ->
        envelope = response.data
        log.debug('getPublicKey', { envelope })
        keyEnv = new PublicKeyEnvelope(envelope)
        Cache.store( Cache.PUBLIC_KEYS, uuid, keyEnv )
        return keyEnv
      .catch (e) ->
        return undefined

    # same as @getPublicKey(), but additionally calls .toRsaPublicKey() on the public key envelope
    getRsaPublicKey: (uuid) ->
      Promise.resolve(axios(Requests.wrapCredentials({
        url    : publicKeyUrl() + '/' + uuid
        method : 'GET'
      })))
      .then (response) ->
        envelope = response.data
        log.debug('getRsaPublicKey', { envelope })
        publicKeyEnvelope = new PublicKeyEnvelope(envelope)
        return publicKeyEnvelope.toRsaPublicKey()
      .catch (e) ->
        return undefined

    #
    # gets a set of public keys for the given user UUIDs in the form of PublicKeyEnvelope, where
    # each public key will become an RSA public key via PublicKeyEnvelope.toRsaPublicKey()
    #
    # @param {Array.<UUID>} - a set user UUIDs for which to get public keys
    # @return {Object.<UUID, RsaPublicKey>} - a map of UUIDs to RSA public keys
    #
    batchGetRsaPublicKeys: (uuids) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            url    : publicKeyUrl()
            method : 'POST'
            data   : JSON.stringify(uuids)
          })
        )
      )
      .then (response) ->
        uuidsToPublicKeyEnvelopes = response.data
        log.debug('batchGetRsaPublicKeys', { uuidsToPublicKeyEnvelopes })

        # transform public keys to RSA public keys
        uuidsToRsaPublicKeys = _.chain(uuidsToPublicKeyEnvelopes)
          .mapValues((envelope) ->
            publicKeyEnvelope = new PublicKeyEnvelope(envelope)
            return publicKeyEnvelope.toRsaPublicKey()
          )
        return uuidsToRsaPublicKeys

      .catch (e) ->
        return undefined

    # gets the user's encrypted salt.
    # request is not wrapped because the user has not auth'ed yet.
    getSalt: (uuid) ->
      cached = Cache.get( Cache.SALTS, uuid )
      if cached?
        return Promise.resolve()
        .then =>
          return cached
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
          ciphertext = new BlockCiphertext(ciphertext)
          Cache.store( Cache.SALTS, uuid, ciphertext )
          return ciphertext

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

    # gets users in the specified realm (initialized users only)
    getInitializedUsers: ({ realm }) ->
      Promise.resolve(axios(Requests.wrapCredentials({
        url    : usersInRealmUrl() + '/initialized/' + realm
        method : 'GET'
      })))
      .then (response) ->
        uuids = response.data
        return uuids

    # gets users in the specified realm (includes users who have not initialized salt/publicKey)
    getUsers: ({ realm }) ->
      Promise.resolve(axios(Requests.wrapCredentials({
        url    : usersInRealmUrl() + '/' + realm
        method : 'GET'
      })))
      .then (response) ->
        uuids = response.data
        return uuids

  return DirectoryApi
