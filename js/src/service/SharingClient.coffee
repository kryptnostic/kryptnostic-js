define 'kryptnostic.sharing-client', [
  'require'
  'bluebird'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.key-storage-api'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.logger'
  'kryptnostic.object-api'
  'kryptnostic.revocation-request'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.sharing-api'
  'kryptnostic.sharing-request'
  'kryptnostic.validators'
], (require) ->

  # libraries
  _                         = require 'lodash'
  Promise                   = require 'bluebird'

  # Kryptnostic apis
  KeyStorageApi             = require 'kryptnostic.key-storage-api'
  ObjectApi                 = require 'kryptnostic.object-api'
  SharingApi                = require 'kryptnostic.sharing-api'

  # Kryptnostic classes
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  CryptoServiceMarshaller   = require 'kryptnostic.crypto-service-marshaller'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'
  RevocationRequest         = require 'kryptnostic.revocation-request'
  RsaCryptoService          = require 'kryptnostic.rsa-crypto-service'
  SharingRequest            = require 'kryptnostic.sharing-request'

  # Kryptnostic utils
  Logger                    = require 'kryptnostic.logger'
  Validators                = require 'kryptnostic.validators'

  logger = Logger.get('SharingClient')

  { validateUuid, validateUuids, validateVersionedObjectKey } = Validators

  #
  # client for granting and revoking shared access to Kryptnostic objects
  #
  class SharingClient

    constructor: ->
      @sharingApi              = new SharingApi()
      @objectApi               = new ObjectApi()
      @cryptoServiceMarshaller = new CryptoServiceMarshaller()
      @cryptoServiceLoader     = new CryptoServiceLoader()

    shareObject: (objectId, uuids, objectSearchPair) ->

      if not validateUuid(objectId)
        return Promise.resolve()

      if _.isEmpty(uuids) or not validateUuids(uuids)
        return Promise.resolve()

      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(objectId)
      )
      .then (versionedObjectKey) =>

        objectSearchPairPromise = undefined
        if objectSearchPair
          objectSearchPairPromise = Promise.resolve(objectSearchPair)
        else
          objectSearchPairPromise = @sharingApi.getObjectSearchPair(versionedObjectKey)

        Promise.join(
          objectSearchPairPromise,
          @cryptoServiceLoader.getObjectCryptoServiceV2(versionedObjectKey),
          KeyStorageApi.getRSAPublicKeys(uuids),
          (objectSearchPair, objectCryptoService, uuidsToRsaPublicKeys) =>

            # transform RSA public key to Base64 seal
            seals = _.mapValues(uuidsToRsaPublicKeys, (rsaPublicKey) =>
              if rsaPublicKey
                rsaCryptoService = new RsaCryptoService({
                  publicKey: rsaPublicKey
                })
                marshalledCrypto = @cryptoServiceMarshaller.marshall(objectCryptoService)
                seal             = rsaCryptoService.encrypt(marshalledCrypto)
                sealBase64       = btoa(seal)
                return sealBase64
            )
            logger.info('seals', seals)

            if !objectSearchPair
              # if we did not get an object search pair, we can omit it from the SharingRequest
              sharingRequest = new SharingRequest({
                id          : versionedObjectKey,
                users       : seals
              })
            else
              # create the object share pair from the object search pair, and encrypt it
              engine = KryptnosticEngineProvider.getEngine()
              objectSharePair = engine.calculateObjectSharePairFromObjectSearchPair(objectSearchPair)

              encryptedObjectSharePair = objectCryptoService.encryptUint8Array(objectSharePair)

              sharingRequest = new SharingRequest({
                id          : versionedObjectKey,
                users       : seals,
                sharingPair : encryptedObjectSharePair
              })

            # send off the object sharing request
            @sharingApi.shareObject(sharingRequest)
        )

    revokeObject: (objectId, uuids) ->
      { revocationRequest } = {}

      if not validateUuid(objectId)
        return Promise.resolve()

      if _.isEmpty(uuids) or not validateUuids(uuids)
        return Promise.resolve()

      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(objectId)
      )
      .then (versionedObjectKey) =>
        revocationRequest = new RevocationRequest { id: versionedObjectKey, users: uuids }
        @sharingApi.revokeObject(revocationRequest)
      .then ->
        logger.info('revoked access', { objectId, uuids })

    processIncomingShares: ->
      Promise.props({
        incomingShares         : @sharingApi.getIncomingShares()
        masterAesCryptoService : @cryptoServiceLoader.getMasterAesCryptoService()
      })
      .then ({ incomingShares, masterAesCryptoService }) =>
        rsaCryptoService = @cryptoServiceLoader.getRsaCryptoService()
        _.forEach(incomingShares, (sharedObject) =>
          try
            if sharedObject.sharingPair
              encodedEncryptedMarshalledCryptoService = sharedObject.publicKeyEncryptedCryptoService
              encryptedMarshalledCryptoService = atob(encodedEncryptedMarshalledCryptoService)
              marshalledCryptoService = rsaCryptoService.decrypt(encryptedMarshalledCryptoService)
              objectCryptoService = @cryptoServiceMarshaller.unmarshall(marshalledCryptoService)

              encryptedSharePair = sharedObject.sharingPair
              decryptedSharePair = objectCryptoService.decryptToUint8Array(encryptedSharePair)

              engine = KryptnosticEngineProvider.getEngine()
              objectSearchPair = engine.calculateObjectSearchPairFromObjectSharePair(decryptedSharePair)

              objectKey = sharedObject.id
              @sharingApi.addObjectSearchPair(objectKey, objectSearchPair)
              @cryptoServiceLoader.setObjectCryptoServiceV2(objectKey, objectCryptoService, masterAesCryptoService)
          catch e
            logger.error('failed to process incoming share')
            logger.error(e)
        )
      .catch (e) ->
        # DOTO - how do we handle failure when processing incoming shares?
        logger.error('failed to process incoming shares', e)

    getObjectSearchPair: (objectId) ->
      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(objectId)
      )
      .then (versionedObjectKey) =>
        @sharingApi.getObjectSearchPair(versionedObjectKey)

  return SharingClient
