define 'soteria.sharing-client', [
  'require'
  'jquery'
  'bluebird'
  'soteria.logger'
  'soteria.sharing-api'
  'soteria.crypto-service-loader'
  'soteria.crypto-service-marshaller'
  'soteria.rsa-compressing-encryption-service'
], (require) ->


  _                               = require 'lodash'
  Promise                         = require 'bluebird'
  Logger                          = require 'soteria.logger'
  SharingApi                      = require 'soteria.sharing-api'
  DirectoryApi                    = require 'soteria.directory-api'
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

      cryptoServiceLoader = new CryptoServiceLoader('demo') # TODO

      cryptoServiceLoader.getObjectCryptoService(id)
      .then (cryptoService) =>
        promiseMap = _.mapValues(_.object(usernames), (empty, username) =>
          return Promise.resolve(@directoryApi.getPublicKey(username))
        )

        Promise.props(promiseMap)
        .then (userKeysMap) =>
          logger.info('userKeysMap', userKeysMap)
          return _.mapValues(userKeysMap, (keyEnvelope, username) =>
            publicKey = keyEnvelope.toRsaPublicKey()
            return new RsaCompressingEncryptionService(keyEnvelope)
          )
        .then (userServicesMap) =>
          seals = _.mapValues(userServicesMap, (rsaCompService, username) =>
            marshalled = @cryptoServiceMarshaller.marshall(cryptoService)
            return rsaCompService.encrypt(marshalled)
          )
          logger.info('seals', seals)

      throw new Error 'unimplemented'

    revokeObject: (id, userKeys) ->
      throw new Error 'unimplemented'

    processIncomingShares: ->
      throw new Error 'unimplemented'

  return SharingClient
