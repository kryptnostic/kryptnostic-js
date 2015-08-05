define 'kryptnostic.sharing-client', [
  'require'
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

  validateUsers = (uuids) ->
    unless _.isArray(usernames)
      log.error('illegal uuids', uuids)
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

    shareObject: (id, uuids) ->
      if _.isEmpty(uuids)
        return Promise.resolve()

      validateId(id)
      validateUsers(uuids)

      { principal }       = CredentialLoader.getCredentials()
      cryptoServiceLoader = new CryptoServiceLoader()
      sharingKey          = ''

      Promise.resolve()
      .then ->
        cryptoServiceLoader.getObjectCryptoService(id)
      .then (cryptoService) =>
        promiseMap = _.mapValues(_.object(uuids), (empty, uuid) =>
          return @directoryApi.getPublicKey(uuid)
        )

        Promise.props(promiseMap)
        .then (uuidsToKeyEnvelopes) =>
          seals = _.chain(uuidsToKeyEnvelopes)
            .mapValues((keyEnvelope, uuid) =>
              publicKey        = keyEnvelope.toRsaPublicKey()
              rsaCryptoService = new RsaCryptoService({ publicKey })
              marshalledCrypto = @cryptoServiceMarshaller.marshall(cryptoService)
              seal             = rsaCryptoService.encrypt(marshalledCrypto)
              sealBase64       = btoa(seal)
              return sealBase64
            )
            .value()

          log.info('seals', seals)
          log.warn('sharing request will be sent with an empty sharing key')
          sharingRequest = new SharingRequest { id, users : seals, sharingKey }
          @sharingApi.shareObject(sharingRequest)

    revokeObject: (id, uuids) ->
      { revocationRequest } = {}

      if _.isEmpty(uuids)
        return Promise.resolve()

      Promise.resolve()
      .then =>
        validateId(id)
        validateUsers(uuids)
        revocationRequest = new RevocationRequest { id, users: uuids }
        @sharingApi.revokeObject(revocationRequest)
      .then ->
        log.info('revoked access', { id, uuids })

    processIncomingShares: ->
      throw new Error 'unimplemented'

  return SharingClient
