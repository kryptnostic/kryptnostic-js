define 'kryptnostic.key-storage-api', [
  'require',
  'axios',
  'bluebird',
  'forge',
  'kryptnostic.block-ciphertext',
  'kryptnostic.caching-service',
  'kryptnostic.configuration',
  'kryptnostic.logger',
  'kryptnostic.requests',
  'kryptnostic.validators'
], (require) ->

  # libraries
  axios   = require 'axios'
  Forge   = require 'forge'
  Promise = require 'bluebird'

  # Kryptnostic
  BlockCiphertext   = require 'kryptnostic.block-ciphertext'

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

  #
  # FHE endpoints
  #

  fheKeysUrl             = -> keyStorageApi() + '/fhe'
  fheHashUrl             = -> fheKeysUrl() + '/hash'
  fhePrivateKeyUrl       = -> fheKeysUrl() + '/private'
  fheSearchPrivateKeyUrl = -> fheKeysUrl() + '/searchprivate'

  #
  # salt endpoints
  #
  saltUrl = (userId) -> keyStorageApi() + '/salt/' + userId

  #
  # RSA endpoints
  #

  rsaKeysUrl         = -> keyStorageApi() + '/rsa'
  rsaPrivateKeyUrl   = -> rsaKeysUrl() + '/private'
  setRSAPublicKeyUrl = -> rsaKeysUrl() + '/public'
  getRSAPublicKeyUrl = (userId) -> rsaKeysUrl() + '/public/' + userId
  getRSAPublicKeyBulkUrl = -> rsaKeysUrl() + '/public/bulk'

  asdfsaf = ->
    if userId then

  #
  # crypto service endpoints
  #

  # cryptoServiceUrl  = (objectId, objectVersion) ->
  #   keyStorageApi() + '/cryptoservice/id/' + objectId + '/' + objectVersion

  aesUrl = -> keyStorageApi() + '/aes'
  aesCryptoServiceUrl = (objectId, objectVersion) ->
    aesUrl() + '/cryptoservice/id/' + objectId + '/' + objectVersion

  #
  # helper functions
  #

  toCacheId = (versionedObjectKey) ->
    return versionedObjectKey.objectId + '/' + versionedObjectKey.objectVersion

  class KeyStorageApi

    #
    # FHE private key
    #

    @getFHEPrivateKey: ->
      Requests.getBlockCiphertextFromUrl(
        fhePrivateKeyUrl()
      )

    @setFHEPrivateKey: (fhePrivateKey) ->
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

    @getFHESearchPrivateKey: ->
      Requests.getBlockCiphertextFromUrl(
        fheSearchPrivateKeyUrl()
      )

    @setFHESearchPrivateKey: (fheSearchPrivateKey) ->
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

    @getFHEHashFunction: ->
      Requests.getAsUint8FromUrl(
        fheHashUrl()
      )

    @setFHEHashFunction: (fheHashFunction) ->
      # TODO - validate FHE hash function is Uint8Array
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

    @getEncryptedSalt: (userId) ->

      if not validateUuid(userId)
        return Promise.resolve(null)

      cachedSalt = Cache.get(Cache.SALTS, userId)
      if cachedSalt
        return Promise.resolve(cachedSalt)

      Promise.resolve(
        axios(
          {
            method : 'GET',
            url    : saltUrl(userId)
          }
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == com.kryptnostic.kodex.v1.crypto.ciphers.BlockCiphertext
          try
            saltBlockCiphertext = new BlockCiphertext(axiosResponse.data)
            Cache.store(Cache.SALTS, userId, saltBlockCiphertext)
            return saltBlockCiphertext
          catch e
            return null
        else
          return null

    @setEncryptedSalt: (userId, credential, saltBlockCiphertext) ->

      if not validateUuid(userId)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials(
            {
              method  : 'POST',
              url     : saltUrl(userId),
              data    : JSON.stringify(saltBlockCiphertext),
              headers : DEFAULT_HEADERS
            },
            {
              principal  : userId,
              credential : credential
            }
          )
        )
      )

    #
    # RSA private key
    #

    @getRSAPrivateKey: ->
      Requests.getBlockCiphertextFromUrl(
        rsaPrivateKeyUrl()
      )

    @setRSAPrivateKey: (privateKeyBlockCiphertext) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : rsaPrivateKeyUrl(),
            data    : JSON.stringify(privateKeyBlockCiphertext),
            headers : DEFAULT_HEADERS
          })
        )
      )

    #
    # RSA public key
    #

    @getRSAPublicKeys: (userIds) ->

      if not validateUuids(userIds)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : getRSAPublicKeyBulkUrl(),
            data    : JSON.stringify(userIds),
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == java.util.Map<java.util.UUID, byte[]>
          try
            # TODO -
            uuidToPublicKeyMap = axiosResponse.data
            uuidToRsaPublicKeyMap = _.mapValues(uuidToPublicKeyMap, (encodedPublicKey) ->
              try
                publicKey       = atob(encodedPublicKey)
                publicKeyBuffer = Forge.util.createBuffer(publicKey, 'raw')
                publicKeyAsn1   = Forge.asn1.fromDer(publicKeyBuffer)
                rsaPublicKey    = Forge.pki.publicKeyFromAsn1(publicKeyAsn1)
                return rsaPublicKey
              catch e
                return null
            )
            return uuidToRsaPublicKeyMap
          catch e
            return null
        else
          return null

    @getRSAPublicKey: (userId) ->
      throw new Error('KeyStorageApi:getRSAPublicKey() - not yet implemented!')

    @setRSAPublicKey: (publicKey) ->
      # TODO - validate publicKey is Uint8Array
      encodedPublicKey = btoa(publicKey)
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : setRSAPublicKeyUrl(),
            data    : publicKey,
            headers : DEFAULT_HEADERS
          })
        )
      )

    #
    # master AES crypto service
    #

    @getMasterAesCryptoService: ->

      objectCacheId = Cache.MASTER_AES_CRYPTO_SERVICE_ID
      cachedObjectCryptoService = Cache.get(Cache.CRYPTO_SERVICES, objectCacheId)

      if cachedObjectCryptoService
        return Promise.resolve(cachedObjectCryptoService)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method : 'GET',
            url    : aesUrl()
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == Base64 encoded byte[]
          masterAesCryptoService = atob(axiosResponse.data)
          objectCacheId = Cache.MASTER_AES_CRYPTO_SERVICE_ID
          Cache.store(Cache.CRYPTO_SERVICES, objectCacheId, masterAesCryptoService)
          return masterAesCryptoService
        else
          return null

    @setMasterAesCryptoService: (masterAesCryptoService) ->

      if not masterAesCryptoService
        return Promise.resolve(null)

      encodedMasterAesCryptoService = btoa(masterAesCryptoService)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'PUT',
            url     : aesUrl(),
            data    : encodedMasterAesCryptoService,
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then ->
        objectCacheId = Cache.MASTER_AES_CRYPTO_SERVICE_ID
        Cache.store(Cache.CRYPTO_SERVICES, objectCacheId, masterAesCryptoService)
        return

    #
    # AES crypto services
    #

    @getAesEncryptedObjectCryptoService: (versionedObjectKey) ->

      if not validateVersionedObjectKey(versionedObjectKey)
        return Promise.resolve(null)

      objectCacheId = toCacheId(versionedObjectKey)
      cachedObjectCryptoService = Cache.get(Cache.CRYPTO_SERVICES, objectCacheId)

      if cachedObjectCryptoService
        return Promise.resolve(cachedObjectCryptoService)

      Requests.getBlockCiphertextFromUrl(
        aesCryptoServiceUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
      )
      .then (objectCryptoServiceBlockCiphertext) ->
        if objectCryptoServiceBlockCiphertext
          Cache.store(Cache.CRYPTO_SERVICES, objectCacheId, objectCryptoServiceBlockCiphertext)
          return objectCryptoServiceBlockCiphertext
        else
          return null

    @setAesEncryptedObjectCryptoService: (versionedObjectKey, objectCryptoServiceBlockCiphertext) ->

      if not validateVersionedObjectKey(versionedObjectKey)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'PUT',
            url     : aesCryptoServiceUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion),
            data    : JSON.stringify(objectCryptoServiceBlockCiphertext),
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then ->
        objectCacheId = toCacheId(versionedObjectKey)
        Cache.store(Cache.CRYPTO_SERVICES, objectCacheId, objectCryptoServiceBlockCiphertext)
        return

  return KeyStorageApi
