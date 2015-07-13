define 'soteria.sharing-client', [
  'require'
  'jquery'
  'bluebird'
  'soteria.logger'
  'soteria.user-utils'
  'soteria.sharing-api'
  'soteria.directory-api'
  'soteria.sharing-request'
  'soteria.credential-store'
  'soteria.crypto-service-loader'
  'soteria.crypto-service-marshaller'
  'soteria.rsa-compressing-encryption-service'
], (require) ->
  _                               = require 'lodash'
  Promise                         = require 'bluebird'
  Logger                          = require 'soteria.logger'
  UserUtils                       = require 'soteria.user-utils'
  SharingApi                      = require 'soteria.sharing-api'
  DirectoryApi                    = require 'soteria.directory-api'
  SharingRequest                  = require 'soteria.sharing-request'
  CredentialStore                 = require 'soteria.credential-store'
  CryptoServiceLoader             = require 'soteria.crypto-service-loader'
  CryptoServiceMarshaller         = require 'soteria.crypto-service-marshaller'
  RsaCompressingEncryptionService = require 'soteria.rsa-compressing-encryption-service'

  logger     = Logger.get('SharingClient')

  validateId = (id) ->
    if !id
      throw new Error 'object id must be specified!'

  validateUsernames = (usernames) ->
    unless _.isArray(usernames)
      throw new Error 'usernames must be a list'


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
      validateId(id)
      validateUsernames(usernames)

      {principal}         = CredentialStore.credentialProvider.load()
      {realm}             = UserUtils.principalToComponents(principal)
      cryptoServiceLoader = new CryptoServiceLoader()
      sharingKey          = ''

      return cryptoServiceLoader.getObjectCryptoService(id)
      .then (cryptoService) =>
        promiseMap = _.mapValues(_.object(usernames), (empty, username) =>
          return Promise.resolve(@directoryApi.getPublicKey(username))
        )

        Promise.props(promiseMap)
        .then (userKeysMap) =>
          seals = _.chain(userKeysMap)
            .mapValues((keyEnvelope, username) =>
              publicKey             = keyEnvelope.toRsaPublicKey()
              rsaCompressingService = new RsaCompressingEncryptionService(publicKey)
              marshalledCrypto      = @cryptoServiceMarshaller.marshall(cryptoService)
              seal                  = rsaCompressingService.encrypt(marshalledCrypto)
              sealBase64            = btoa(seal)
              return sealBase64
            )
            .mapKeys((seal, username) ->
              return UserUtils.componentsToPrincipal({realm, username})
            )
            .value()

          logger.info('seals', seals)
          logger.warn('sharing request will be sent with an empty sharing key')
          sharingRequest = new SharingRequest({id, users : seals, sharingKey})
          @sharingApi.shareObject(sharingRequest)

    revokeObject: (id, userKeys) ->
      throw new Error 'unimplemented'

    processIncomingShares: ->
      throw new Error 'unimplemented'

  return SharingClient