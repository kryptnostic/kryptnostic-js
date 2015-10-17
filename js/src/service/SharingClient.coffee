define 'kryptnostic.sharing-client', [
  'require'
  'bluebird'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.crypto-service-marshaller'
  'kryptnostic.directory-api'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.logger'
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
  DirectoryApi              = require 'kryptnostic.directory-api'
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

  { validateId, validateUuids } = Validators

  #
  # client for granting and revoking shared access to Kryptnostic objects
  #
  class SharingClient

    constructor: ->
      @sharingApi              = new SharingApi()
      @directoryApi            = new DirectoryApi()
      @cryptoServiceMarshaller = new CryptoServiceMarshaller()
      @cryptoServiceLoader     = CryptoServiceLoader.get()

    #
    # shares an object with the given object ID with the given set of user UUIDs
    #
    # @param {String} objectId
    # @param {Array<String>} uuids
    #
    shareObject: (objectId, uuids, objectSearchPair) ->

      if _.isEmpty(uuids)
        return Promise.resolve()

      validateId(objectId)
      validateUuids(uuids)

      objectSearchPairPromise = undefined
      if objectSearchPair?
        objectSearchPairPromise = Promise.resolve(objectSearchPair)
      else
        objectSearchPairPromise = @sharingApi.getObjectSearchPair(objectId)

      Promise.join(
        objectSearchPairPromise,
        @cryptoServiceLoader.getObjectCryptoService(objectId),
        @directoryApi.getRsaPublicKeys(uuids),
        (objectSearchPair, objectCryptoService, uuidsToRsaPublicKeys) =>

          # transform RSA public key to Base64 seal
          seals = _.mapValues(uuidsToRsaPublicKeys, (rsaPublicKey) =>
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
              id          : objectId,
              users       : seals
            })
          else
            # create the object share pair from the object search pair, and encrypt it
            objectSharePair = KryptnosticEngineProvider.getEngine()
              .calculateObjectSharePairFromObjectSearchPair(objectSearchPair)

            encryptedObjectSharePair = objectCryptoService.encryptUint8Array(objectSharePair)

            sharingRequest = new SharingRequest({
              id          : objectId,
              users       : seals,
              sharingPair : encryptedObjectSharePair
            })

          # send off the object sharing request
          @sharingApi.shareObject(sharingRequest)
      )
      .catch (e) ->
        logger.error('failed to share object', e)
        return null

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
        logger.info('revoked access', { id, uuids })

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
            if sharedObject? and sharedObject.sharingPair?
              encryptedSharePair = sharedObject.sharingPair
              decryptedSharePair = objectCryptoService.decryptToUint8Array(encryptedSharePair)
              objectSearchPair = KryptnosticEngineProvider.getEngine()
                .calculateObjectSearchPairFromObjectSharePair(decryptedSharePair)
              @sharingApi.addObjectSearchPair(objectId, objectSearchPair)
        )
      .catch (e) ->
        # DOTO - how do we handle failure when processing incoming shares?
        logger.error('failed to process incoming shares', e)



  return SharingClient
