define 'kryptnostic.crypto-service-migrator', [
  'require',
  'axios',
  'bluebird',
  'kryptnostic.configuration',
  'kryptnostic.credential-loader',
  'kryptnostic.crypto-service-loader',
  'kryptnostic.crypto-service-marshaller',
  'kryptnostic.rsa-crypto-service',
  'kryptnostic.logger',
  'kryptnostic.requests',
  'kryptnostic.validators'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # kryptnostic
  CredentialLoader        = require 'kryptnostic.credential-loader'
  CryptoServiceLoader     = require 'kryptnostic.crypto-service-loader'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  RsaCryptoService        = require 'kryptnostic.rsa-crypto-service'

  # utils
  Config     = require 'kryptnostic.configuration'
  Logger     = require 'kryptnostic.logger'
  Requests   = require 'kryptnostic.requests'
  Validators = require 'kryptnostic.validators'

  # constants
  OBJECT_ID_WHITELIST = {
    '58694df5-e76a-4053-8c98-281bd9f35167' : true,
    'd1e02b1f-575b-4ae8-9bfa-33b876ef8cee' : true,
    '3ed853a2-2fe5-4224-b6a8-479fba6556f3' : true,
    '37b93117-991d-414f-9f73-b99932f8d019' : true
  }
  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  {
    validateUuid
  } = Validators

  logger = Logger.get('CryptoServiceMigrator')

  keyStorageApi = -> Config.get('servicesUrl') + '/keys'
  rsaCryptoServicesBulkUrl = -> keyStorageApi() + '/bulk/cryptoservices'
  aesCryptoServiceMigrationUrl = (objectId) -> keyStorageApi() + '/aes/cryptoservice-migration/id/' + objectId

  getRSACryptoServicesForUser = ->

    Promise.resolve(
      axios(
        Requests.wrapCredentials({
          method  : 'GET',
          url     : rsaCryptoServicesBulkUrl()
        })
      )
    )
    .then (axiosResponse) ->
      if axiosResponse and axiosResponse.data
        # axiosResponse.data == java.util.Map<java.util.UUID, byte[]>
        return axiosResponse.data
      else
        return null

  setAesEncryptedObjectCryptoServiceForMigration = (objectId, objectCryptoServiceBlockCiphertext) ->

    if not validateUuid(objectId)
      return Promise.resolve()

    Promise.resolve(
      axios(
        Requests.wrapCredentials({
          method  : 'PUT',
          url     : aesCryptoServiceMigrationUrl(objectId),
          data    : JSON.stringify(objectCryptoServiceBlockCiphertext),
          headers : DEFAULT_HEADERS
        })
      )
    )

  class CryptoServiceMigrator

    constructor: ->
      @credentialLoader        = new CredentialLoader()
      @cryptoServiceLoader     = new CryptoServiceLoader()
      @cryptoServiceMarshaller = new CryptoServiceMarshaller()
      @rsaCryptoService        = new RsaCryptoService(@credentialLoader.getCredentials().keypair)

    migrateRSACryptoServices: ->

      Promise.props({
        masterAesCryptoService : @cryptoServiceLoader.getMasterAesCryptoService(),
        objectCryptoServiceMap : getRSACryptoServicesForUser()
      })
      .then ({ masterAesCryptoService, objectCryptoServiceMap }) =>

        migrationPromises = _.map(objectCryptoServiceMap, (serializedCryptoService, objectId) =>

          if _.isEmpty(serializedCryptoService) or not OBJECT_ID_WHITELIST[objectId]
            return Promise.resolve()

          logger.info('attempting to migrate RSA crypto service for objectId: ' + objectId)

          try

            rsaEncryptedMarshalledCryptoService = atob(serializedCryptoService)
            marshalledCryptoService = @rsaCryptoService.decrypt(rsaEncryptedMarshalledCryptoService)
            objectCryptoService = @cryptoServiceMarshaller.unmarshall(marshalledCryptoService)

            marshalledCryptoService = @cryptoServiceMarshaller.marshall(objectCryptoService)
            encryptedCryptoService  = masterAesCryptoService.encrypt(marshalledCryptoService)

            Promise.resolve(
              setAesEncryptedObjectCryptoServiceForMigration(objectId, encryptedCryptoService)
            )
            .then ->
              logger.info('successfully migrated RSA crypto service for objectId: ' + objectId)
              return
            .catch (e) ->
              logger.info('failed to migrate RSA crypto service for objectId: ' + objectId)
              return

          catch e
            logger.error(e)
            logger.error('error while migrating RSA crypto service for objectId: ' + objectId)
            return Promise.resolve()
        )

        Promise.all(migrationPromises)
        .catch (e) ->
          logger.error(e)
          logger.error('error during RSA crypto service migration')

  return CryptoServiceMigrator
