define 'kryptnostic.sharing-client', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.validators'
  'kryptnostic.sharing-api'
  'kryptnostic.directory-api'
  'kryptnostic.sharing-request'
  'kryptnostic.revocation-request'
  'kryptnostic.credential-loader'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.share-processing-service'
], (require) ->
  _                       = require 'lodash'
  Promise                 = require 'bluebird'
  Logger                  = require 'kryptnostic.logger'
  validators              = require 'kryptnostic.validators'
  SharingApi              = require 'kryptnostic.sharing-api'
  DirectoryApi            = require 'kryptnostic.directory-api'
  SharingRequest          = require 'kryptnostic.sharing-request'
  RevocationRequest       = require 'kryptnostic.revocation-request'
  CredentialLoader        = require 'kryptnostic.credential-loader'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  CryptoServiceLoader     = require 'kryptnostic.crypto-service-loader'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  ShareProcessingService  = require 'kryptnostic.share-processing-service'

  log     = Logger.get('SharingClient')

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
      @shareProcessingService  = new ShareProcessingService()
      @credentialLoader        = new CredentialLoader()

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
        validateUuids(uuids)
        revocationRequest = new RevocationRequest { id, users: uuids }
        @sharingApi.revokeObject(revocationRequest)
      .then ->
        log.info('revoked access', { id, uuids })

    processIncomingShares : ->
      Promise.resolve()
      .then =>
        @sharingApi.getIncomingShares()
      .then (shares) =>
        @shareProcessingService.processShares(shares)

    registerSearchKeys : (encryptedSearchObjectKeys) ->
      if _.isEmpty(encryptedSearchObjectKeys)
        return Promise.resolve()
      else
        return @sharingApi.registerSearchKeys(encryptedSearchObjectKeys)

  return SharingClient
