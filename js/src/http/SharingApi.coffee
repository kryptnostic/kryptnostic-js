define 'kryptnostic.sharing-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.binary-utils'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.validators'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'
  Config      = require 'kryptnostic.configuration'
  Logger      = require 'kryptnostic.logger'
  Requests    = require 'kryptnostic.requests'
  Validators  = require 'kryptnostic.validators'

  # constants
  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  { validateVersionedObjectKey } = Validators

  logger = Logger.get('SharingApi')

  sharingUrl             = -> Config.get('servicesUrlV2') + '/share'
  shareObjectUrl         = -> sharingUrl() + '/object'
  revokeObjectUrl        = -> sharingUrl() + '/object'
  incomingSharesUrl      = -> sharingUrl() + '/object'
  addObjectSearchPairUrl = -> sharingUrl() + '/keys'
  getObjectSearchPairUrl = (objectId, objectVersion) ->
    sharingUrl() + '/keys/id/' + objectId + '/' + objectVersion

  class SharingApi

    # get all incoming shares
    getIncomingShares: ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method : 'GET'
            url    : incomingSharesUrl()
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == java.util.Set<com.kryptnostic.v2.sharing.models.Share>
          return axiosResponse.data;
        else
          return null

    # share an object
    shareObject: (sharingRequest) ->
      sharingRequest.validate()
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : shareObjectUrl()
            data    : JSON.stringify(sharingRequest)
            headers : DEFAULT_HEADERS
          })
        )
      )

    # revoke access to an object
    revokeObject: (revocationRequest) ->
      revocationRequest.validate()
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'DELETE'
            url     : revokeObjectUrl()
            data    : JSON.stringify(revocationRequest)
            headers : DEFAULT_HEADERS
          })
        )
      )

    getObjectSearchPair: (versionedObjectKey) ->

      if not validateVersionedObjectKey(versionedObjectKey)
        return Promise.resolve(null)

      Requests.getAsUint8FromUrl(
        getObjectSearchPairUrl(versionedObjectKey.objectId, versionedObjectKey.objectVersion)
      )

    addObjectSearchPair: (versionedObjectKey, objectSearchPair) ->

      if not validateVersionedObjectKey(versionedObjectKey)
        return Promise.resolve(null)

      versionedObjectSearchPair = {
        objectKey        : versionedObjectKey
        objectSearchPair : BinaryUtils.uint8ToBase64(objectSearchPair)
      }
      requestData = [versionedObjectSearchPair]

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST'
            url     : addObjectSearchPairUrl()
            data    : requestData
            headers : DEFAULT_HEADERS
          })
        )
      )

  return SharingApi
