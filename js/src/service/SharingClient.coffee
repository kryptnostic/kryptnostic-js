define 'kryptnostic.sharing-client', [
  'require'
  'jquery'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.user-utils'
  'kryptnostic.sharing-api'
  'kryptnostic.directory-api'
  'kryptnostic.sharing-request'
  'kryptnostic.revocation-request'
  'kryptnostic.credential-loader'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
], (require) ->
  _                       = require 'lodash'
  Promise                 = require 'bluebird'
  Logger                  = require 'kryptnostic.logger'
  UserUtils               = require 'kryptnostic.user-utils'
  SharingApi              = require 'kryptnostic.sharing-api'
  DirectoryApi            = require 'kryptnostic.directory-api'
  SharingRequest          = require 'kryptnostic.sharing-request'
  RevocationRequest       = require 'kryptnostic.revocation-request'
  CredentialLoader        = require 'kryptnostic.credential-loader'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  CryptoServiceLoader     = require 'kryptnostic.crypto-service-loader'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'

  log     = Logger.get('SharingClient')

  validateId = (id) ->
    if !id
      log.error('illegal id', id)
      throw new Error 'object id must be specified!'

  validateUsernames = (usernames) ->
    unless _.isArray(usernames)
      log.error('illegal usernames', usernames)
      throw new Error 'usernames must be a list'

  usernamesToKeys = (usernames, realm) ->
    return _.map usernames, (username) ->
      return UserUtils.componentsToUserKey {username, realm}

  #
  # Client for granting and revoking shared access to Kryptnostic objects.
  # Author: rbuckheit
  #
  class SharingClient

    constructor: ->
      @sharingApi              = new SharingApi()
      @directoryApi            = new DirectoryApi()
      @cryptoServiceMarshaller = new CryptoServiceMarshaller()

    shareObject: (id, usernames) ->
      if _.isEmpty(usernames)
        return Promise.resolve()

      validateId(id)
      validateUsernames(usernames)

      {principal}         = CredentialLoader.getCredentials()
      realm               = UserUtils.principalToComponents(principal).realm
      cryptoServiceLoader = new CryptoServiceLoader()
      sharingKey          = ''

      Promise.resolve()
      .then ->
        cryptoServiceLoader.getObjectCryptoService(id)
      .then (cryptoService) =>
        promiseMap = _.mapValues(_.object(usernames), (empty, username) =>
          return Promise.resolve(@directoryApi.getPublicKey(username))
        )

        Promise.props(promiseMap)
        .then (userKeysMap) =>
          seals = _.chain(userKeysMap)
            .mapValues((keyEnvelope, username) =>
              publicKey        = keyEnvelope.toRsaPublicKey()
              rsaCryptoService = new RsaCryptoService({publicKey})
              marshalledCrypto = @cryptoServiceMarshaller.marshall(cryptoService)
              seal             = rsaCryptoService.encrypt(marshalledCrypto)
              sealBase64       = btoa(seal)
              return sealBase64
            )
            .mapKeys((seal, username) ->
              return UserUtils.componentsToPrincipal({realm, username})
            )
            .value()

          log.info('seals', seals)
          log.warn('sharing request will be sent with an empty sharing key')
          sharingRequest = new SharingRequest({id, users : seals, sharingKey})
          @sharingApi.shareObject(sharingRequest)

    revokeObject: (id, usernames) ->
      {revocationRequest} = {}

      if _.isEmpty(usernames)
        return Promise.resolve()

      Promise.resolve()
      .then =>
        validateId(id)
        validateUsernames(usernames)

        {principal} = CredentialLoader.getCredentials()
        realm       = UserUtils.principalToComponents(principal).realm
        userKeys    = usernamesToKeys(usernames, realm)

        log.error('userkeys', userKeys)

        revocationRequest = new RevocationRequest { id, userKeys }
      .then ->
        @sharingApi.revokeObject(revocationRequest)
      .then ->
        log.info('revoked access', revocationRequest)

    processIncomingShares: ->
      throw new Error 'unimplemented'

  return SharingClient
