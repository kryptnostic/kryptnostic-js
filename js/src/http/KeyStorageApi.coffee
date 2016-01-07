define 'kryptnostic.key-storage-api', [
  'require',
  'axios',
  'bluebird',
  'kryptnostic.caching-service',
  'kryptnostic.configuration',
  'kryptnostic.logger',
  'kryptnostic.requests',
  'kryptnostic.validators',
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  Cache      = require 'kryptnostic.caching-service'
  Config     = require 'kryptnostic.configuration'
  Logger     = require 'kryptnostic.logger'
  Requests   = require 'kryptnostic.requests'
  Validators = require 'kryptnostic.validators'

  {
    validateUuid,
    validateUuids,
    validateVersionedObjectKey,
    validateObjectCryptoService
  } = Validators

  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  logger = Logger.get('KeyStorageApi')

  keyStorageApi = -> Config.get('servicesUrlV2') + '/keys'
  saltUrl       = (userId) -> keyStorageApi() + '/salt/' + userId

  #
  # FHE endpoints
  #

  fheKeysUrl             = -> keyStorageApi() + '/fhe'
  fheHashUrl             = -> fheKeysUrl() + '/hash'
  fhePrivateKeyUrl       = -> fheKeysUrl() + '/private'
  fheSearchPrivateKeyUrl = -> fheKeysUrl() + '/searchprivate'

  #
  # RSA endpoints
  #

  rsaKeysUrl       = -> keyStorageApi() + '/rsa'
  rsaPublicKeyUrl  = -> rsaKeysUrl() + '/public'
  rsaPrivateKeyUrl = -> rsaKeysUrl() + '/private'

  #
  # crypto service endpoints
  #

  cryptoServiceUrl  = (objectId, objectVersion) ->
    keyStorageApi() + '/cryptoservice/id/' + objectId + '/' + objectVersion

  #
  # helper functions
  #

  toCacheId = (versionedObjectKey) ->
    return versionedObjectKey.objectId + '/' + versionedObjectKey.objectVersion

  class KeyStorageApi

    #
    # FHE private key
    #

    getFHEPrivateKey: ->
      Requests.getBlockCiphertextFromUrl(
        fhePrivateKeyUrl()
      )

    setFHEPrivateKey: (fhePrivateKey) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : fhePrivateKeyUrl(),
            data    : fhePrivateKey,
            headers : DEFAULT_HEADERS,
          })
        )
      )

    #
    # FHE search private key
    #

    getFHESearchPrivateKey: ->
      Requests.getBlockCiphertextFromUrl(
        fheSearchPrivateKeyUrl()
      )

    setFHESearchPrivateKey: (fheSearchPrivateKey) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : fheSearchPrivateKeyUrl(),
            data    : fheSearchPrivateKey,
            headers : DEFAULT_HEADERS
          })
        )
      )

    #
    # FHE client hash function
    #

    getFHEHashFunction: ->
      Requests.getAsUint8FromUrl(
        fheHashUrl()
      )

    setFHEHashFunction: (fheHashFunction) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : fheHashUrl(),
            data    : fheHashFunction,
            headers : DEFAULT_HEADERS
          })
        )
      )

    #
    # encrypted salt
    #

    getEncryptedSalt: (userId) ->
      throw new Error('not yet implemented')

    setEncryptedSalt: (userId, blockCiphertext) ->
      throw new Error('not yet implemented')

    #
    # crypto services
    #

    getAesEncryptedObjectCryptoService: (versionedObjectKey) ->
      throw new Error('not yet implemented')

    setAesEncryptedObjectCryptoService: (versionedObjectKey, serializedObjectCryptoService) ->
      throw new Error('not yet implemented')

    #
    # @deprecated - use getAesEncryptedObjectCryptoService() instead
    #
    getObjectCryptoService: (versionedObjectKey) ->

      if not validateVersionedObjectKey(versionedObjectKey)
        return Promise.resolve(null)

      objectCacheId = toCacheId(versionedObjectKey)
      cachedObjectCryptoService = Cache.get(Cache.CRYPTO_SERVICES, objectCacheId)

      if cachedObjectCryptoService?
        return Promise.resolve(cachedObjectCryptoService)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method : 'GET',
            url    : cryptoServiceUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Base64 encoded byte[]
          encodedObjectCryptoService = axiosResponse.data
          Cache.store(Cache.CRYPTO_SERVICES, objectCacheId, encodedObjectCryptoService)
          return encodedObjectCryptoService
        else
          return null

    #
    # @deprecated - use setAesEncryptedObjectCryptoService() instead
    #
    setObjectCryptoService: (versionedObjectKey, objectCryptoService) ->

      if not validateVersionedObjectKey(versionedObjectKey) or
          not validateObjectCryptoService(objectCryptoService)
        return Promise.resolve(null)

      encodedObjectCryptoService = btoa(objectCryptoService)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'PUT',
            url     : cryptoServiceUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion),
            data    : encodedObjectCryptoService,
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then ->
        objectCacheId = toCacheId(versionedObjectKey)
        Cache.store(Cache.CRYPTO_SERVICES, objectCacheId, encodedObjectCryptoService)
        return

  return KeyStorageApi
