define 'kryptnostic.sharing-client', [
  'require'
  'bluebird'
  'kryptnostic.credential-loader'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.directory-api'
  'kryptnostic.kryptnostic-engine'
  'kryptnostic.logger'
  'kryptnostic.object-sharing-service'
  'kryptnostic.revocation-request'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.sharing-api'
  'kryptnostic.sharing-request'
  'kryptnostic.validators'
], (require) ->

  # libraries
  _                       = require 'lodash'
  Promise                 = require 'bluebird'

  # Kryptnostic apis
  DirectoryApi            = require 'kryptnostic.directory-api'
  SharingApi              = require 'kryptnostic.sharing-api'

  # Kryptnostic classes
  CredentialLoader        = require 'kryptnostic.credential-loader'
  CryptoServiceLoader     = require 'kryptnostic.crypto-service-loader'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  KryptnosticEngine       = require 'kryptnostic.kryptnostic-engine'
  ObjectSharingService    = require 'kryptnostic.object-sharing-service'
  RevocationRequest       = require 'kryptnostic.revocation-request'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'
  SharingRequest          = require 'kryptnostic.sharing-request'

  # Kryptnostic utils
  Logger                  = require 'kryptnostic.logger'
  Validators              = require 'kryptnostic.validators'

  log = Logger.get('SharingClient')

  { validateId, validateUuids } = Validators

  #
  # Client for granting and revoking shared access to Kryptnostic objects.
  # Author: rbuckheit
  #
  class SharingClient

    constructor: ->
      @engine                  = new KryptnosticEngine()
      @sharingApi              = new SharingApi()
      @directoryApi            = new DirectoryApi()
      @cryptoServiceMarshaller = new CryptoServiceMarshaller()
      @cryptoServiceLoader     = new CryptoServiceLoader()
      @credentialLoader        = new CredentialLoader()
      @objectSharingService    = new ObjectSharingService()

    #
    # shares an object with the given object ID with the given set of user UUIDs
    #
    # @param {String} objectId
    # @param {Array<String>} uuids
    #
    shareObject: (objectId, uuids) ->

      if _.isEmpty(uuids)
        return Promise.resolve()

      validateId(objectId)
      validateUuids(uuids)

      { principal } = @credentialLoader.getCredentials()

      Promise.join(
        @sharingApi.getObjectIndexPair(objectId),
        @cryptoServiceLoader.getObjectCryptoService(objectId),
        @directoryApi.batchGetRsaPublicKeys(uuids),
        (objectIndexPair, objectCryptoService, uuidsToRsaPublicKeys) ->

        # create the object sharing pair from the object index pair, and encrypt it
        objectSharingPair = @engine.getObjectSharingPairFromObjectIndexPair(objectIndexPair)
        encryptedObjectSharingPair = objectCryptoService.encryptUint8Array(objectSharingPair)

        # transform RSA public key to Base64 seal
        seals = _.mapValues(uuidsToRsaPublicKeys, (rsaPublicKey) =>
          rsaCryptoService = new RsaCryptoService({ rsaPublicKey })
          marshalledCrypto = @cryptoServiceMarshaller.marshall(objectCryptoService)
          seal             = rsaCryptoService.encrypt(marshalledCrypto)
          sealBase64       = btoa(seal)
          return sealBase64
        )
        log.info('seals', seals)

        # send off the object sharing request
        sharingRequest = new SharingRequest({
          id          : objectId,
          users       : seals,
          sharingPair : encryptedObjectSharingPair
        })
        @sharingApi.shareObject(sharingRequest)
      )
      .catch (e) ->
        # DOTO - how do we handle failure when sharing an object?
        log.error('failed to share object', e)
        return undefined

    revokeObject: (id, uuids) ->
      { revocationRequest } = {}

      if _.isEmpty(uuids)
        return Promise.resolve()

      Promise
      .resolve()
      .then =>
        validateId(id)
        validateUuids(uuids)
        revocationRequest = new RevocationRequest { id, users: uuids }
        @sharingApi.revokeObject(revocationRequest)
      .then ->
        log.info('revoked access', { id, uuids })

    processIncomingShares: ->
      Promise
      .resolve()
      .then =>
        @sharingApi.getIncomingShares()
      .then (incomingShares) =>
        _.forEach(incomingShares, (sharedObject) =>
          objectId = sharedObject.id
          Promise.resolve()
          .then =>
            @cryptoServiceLoader.getObjectCryptoService(
              objectId,
              { expectMiss: false } # ObjectCryptoService should exist
            )
          .then (objectCryptoService) =>
            encryptedSharingPair = sharedObject.encryptedSharingPair
            decryptedSharingPair = objectCryptoService.decryptToUint8Array(encryptedSharingPair)
            objectIndexPair = @engine.getObjectIndexPairFromObjectSharingPair(decryptedSharingPair)
            @sharingApi.addIndexPair(objectId, objectIndexPair)
        )
      .catch (e) ->
        # DOTO - how do we handle failure when processing incoming shares?
        log.error('failed to process incoming shares', e)
        return undefined



  return SharingClient
