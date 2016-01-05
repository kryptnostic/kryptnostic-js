define 'kryptnostic.key-storage-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.validators'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  Config     = require 'kryptnostic.configuration'
  Logger     = require 'kryptnostic.logger'
  Requests   = require 'kryptnostic.requests'
  Validators = require 'kryptnostic.validators'

  { validateUuid, validateUuids } = Validators

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

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

  cryptoServiceUrl  = -> keyStorageApi() + '/cryptoservice'
  cryptoServicesUrl = -> keyStorageApi() + '/cryptoservices'

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
            method  : 'POST'
            url     : fhePrivateKeyUrl()
            data    : fhePrivateKey
            headers : _.clone(DEFAULT_HEADER)
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
            method  : 'POST'
            url     : fheSearchPrivateKeyUrl()
            data    : fheSearchPrivateKey
            headers : _.clone(DEFAULT_HEADER)
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
            method  : 'POST'
            url     : fheHashUrl()
            data    : fheHashFunction
            headers : _.clone(DEFAULT_HEADER)
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

    getObjectCryptoService: (objectId) ->
      throw new Error('not yet implemented')

    getObjectCryptoServices: (objectIds) ->

      if not validateUuids(objectIds)
        Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : cryptoServicesUrl()
            data    : JSON.stringify(objectIds)
            headers : _.clone(DEFAULT_HEADER)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Map<java.util.UUID, byte[]>
          return axiosResponse.data
        else
          return null

  return KeyStorageApi
