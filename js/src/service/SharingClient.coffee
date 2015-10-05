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

  log = Logger.get('SharingClient')

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
    shareObject: (objectId, uuids) ->

      if _.isEmpty(uuids)
        return Promise.resolve()

      validateId(objectId)
      validateUuids(uuids)

      Promise.join(
        @sharingApi.getObjectSearchPair(objectId),
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
          log.info('seals', seals)

          if !objectSearchPair
            # if we did not get an object search pair, we can omit it from the SharingRequest
            sharingRequest = new SharingRequest({
              id          : objectId,
              users       : seals
            })
          else
            # create the object share pair from the object search pair, and encrypt it
            objectSharePair = KryptnosticEngineProvider
              .getEngine()
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
      # DOTO - how do we handle failure when sharing an object?
      # .catch (e) ->
      #   log.error('failed to share object', e)
      #   return undefined

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
            encryptedSharePair = sharedObject.encryptedSharingPair
            decryptedSharePair = objectCryptoService.decryptToUint8Array(encryptedSharingPair)
            objectSearchPair = KryptnosticEngineProvider
              .getEngine()
              .calculateObjectSearchPairFromObjectSharePair(decryptedSharePair)
            @sharingApi.addObjectSearchPair(objectId, objectSearchPair)
        )
      # DOTO - how do we handle failure when processing incoming shares?
      # .catch (e) ->
      #   log.error('failed to process incoming shares', e)
      #   return undefined



  return SharingClient
