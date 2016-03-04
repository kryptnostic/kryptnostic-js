# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.sharing-client', [
  'require'
  'bluebird'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.key-storage-api'
  'kryptnostic.kryptnostic-engine'
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
  KryptnosticEngine         = require 'kryptnostic.kryptnostic-engine'
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

    #
    # @public
    # @param objectIdOrKey - the UUID or latest VersionedObjectKey of the object to share
    # @param uuids - the UUIDs with which to share the object
    # @param isSearchable - boolean flag for deciding whether or not the object (and its children) should be searchable
    #
    shareObject: (objectIdOrKey, uuids, isSearchable) =>

      if _.isEmpty(uuids) or not validateUuids(uuids)
        return Promise.resolve()

      objectKeyPromise = null
      if validateVersionedObjectKey(objectIdOrKey)
        objectKeyPromise = Promise.resolve(objectIdOrKey)
      else if validateUuid(objectIdOrKey)
        objectKeyPromise = @objectApi.getLatestVersionedObjectKey(objectIdOrKey)
      else
        return Promise.resolve()

      return Promise.resolve(objectKeyPromise)
        .then (latestVersionedObjectKey) ->
          if latestVersionedObjectKey?
            share(latestVersionedObjectKey, uuids, isSearchable)
          return

    #
    # parameters to a private function are assumed valid since it is expected for the calling function to validate
    #
    # @private
    # @param objectKey - the latest VersionedObjectKey of the object to share
    # @param uuids - the UUIDs with which to share the object
    # @param isSearchable - boolean flag for deciding whether or not the object (and its children) should be searchable
    #
    share = (objectKey, uuids, isSearchable) ->

      { objectSearchPair, addObjectSearchPairPromise, sharingRequest } = {}

      engine = KryptnosticEngineProvider.getEngine()

      cryptoServiceLoader = new CryptoServiceLoader()
      cryptoServiceMarshaller = new CryptoServiceMarshaller()
      sharingApi = new SharingApi()

      Promise.join(
        sharingApi.getObjectSearchPair(objectKey),
        cryptoServiceLoader.getObjectCryptoServiceV2(objectKey),
        KeyStorageApi.getRSAPublicKeys(uuids),
        (objectSearchPair, objectCryptoService, uuidsToRsaPublicKeys) ->

          # transform RSA public key to Base64 seal
          seals = _.mapValues(uuidsToRsaPublicKeys, (rsaPublicKey) ->
            if rsaPublicKey
              rsaCryptoService = new RsaCryptoService({
                publicKey: rsaPublicKey
              })
              marshalledCrypto = cryptoServiceMarshaller.marshall(objectCryptoService)
              seal             = rsaCryptoService.encrypt(marshalledCrypto)
              sealBase64       = btoa(seal)
              return sealBase64
          )

          if KryptnosticEngine.isValidObjectSearchPair(objectSearchPair)
            objectSharePair = engine.calculateObjectSharePairFromObjectSearchPair(objectSearchPair)
            encryptedObjectSharePair = objectCryptoService.encryptUint8Array(objectSharePair)
            sharingRequest = new SharingRequest({
              id          : objectKey,
              users       : seals,
              sharingPair : encryptedObjectSharePair
            })
          else
            sharingRequest = new SharingRequest({
              id          : objectKey,
              users       : seals
            })

          sharingApi.shareObject(sharingRequest)
          return
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

  return SharingClient
