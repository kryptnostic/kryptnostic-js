define 'kryptnostic.sharing-client', [
  'require'
  'bluebird'
  'kryptnostic.credential-loader'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.directory-api'
  'kryptnostic.logger'
  'kryptnostic.object-sharing-service'
  'kryptnostic.revocation-request'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.sharing-api'
  'kryptnostic.sharing-request'
  'kryptnostic.validators'
], (require) ->
  _                       = require 'lodash'
  Promise                 = require 'bluebird'
  CredentialLoader        = require 'kryptnostic.credential-loader'
  CryptoServiceLoader     = require 'kryptnostic.crypto-service-loader'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  DirectoryApi            = require 'kryptnostic.directory-api'
  Logger                  = require 'kryptnostic.logger'
  ObjectSharingService    = require 'kryptnostic.object-sharing-service'
  RevocationRequest       = require 'kryptnostic.revocation-request'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  SharingApi              = require 'kryptnostic.sharing-api'
  SharingRequest          = require 'kryptnostic.sharing-request'
  validators              = require 'kryptnostic.validators'

  log = Logger.get('SharingClient')

  { validateId, validateUuids } = validators

  #
  # Client for granting and revoking shared access to Kryptnostic objects.
  # Author: rbuckheit
  #
  class SharingClient

    constructor: ->
      @sharingApi              = new SharingApi()
      @directoryApi            = new DirectoryApi()
      @cryptoServiceMarshaller = new CryptoServiceMarshaller()
      @cryptoServiceLoader     = new CryptoServiceLoader()
      @credentialLoader        = new CredentialLoader()
      @objectSharingService    = new ObjectSharingService()

    shareObject: (id, uuids) ->
      if _.isEmpty(uuids)
        return Promise.resolve()

      validateId(id)
      validateUuids(uuids)

      { principal } = @credentialLoader.getCredentials()
      sharingKey    = ''

      Promise.resolve()
      .then =>
        @cryptoServiceLoader.getObjectCryptoService(id)
      .then (cryptoService) =>
        promiseMap = _.mapValues(_.object(uuids), (empty, uuid) =>
          return @directoryApi.getRsaPublicKey(uuid)
        )

        Promise.props(promiseMap)
        .then (uuidsToRsaPublicKeys) =>
          seals = _.chain(uuidsToRsaPublicKeys)
            .mapValues((rsaPublicKey, uuid) =>
              rsaCryptoService = new RsaCryptoService({ rsaPublicKey })
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

          _.map(uuidsToRsaPublicKeys, (rsaPublicKey, uuid) =>
            @objectSharingService.shareObject(id, rsaPublicKey)
          )

    revokeObject: (id, uuids) ->
      { revocationRequest } = {}

      if _.isEmpty(uuids)
        return Promise.resolve()

      Promise.resolve()
      .then =>
        validateId(id)
        validateUuids(uuids)
        revocationRequest = new RevocationRequest { id, users: uuids }
        @sharingApi.revokeObject(revocationRequest)
      .then ->
        log.info('revoked access', { id, uuids })

    processIncomingShares : ->
      throw new Error 'unimplemented'

  return SharingClient
