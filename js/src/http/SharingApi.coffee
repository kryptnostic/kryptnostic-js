define 'kryptnostic.sharing-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.requests'
  'kryptnostic.logger'
], (require) ->

  axios    = require 'axios'
  Requests = require 'kryptnostic.requests'
  Logger   = require 'kryptnostic.logger'
  Config   = require 'kryptnostic.configuration'
  Promise  = require 'bluebird'

  TYPE_PATH   = '/type'
  SHARE_PATH  = '/share'
  REVOKE_PATH = '/revoke'
  OBJECT_PATH = '/object'
  KEYS_PATH   = '/keys'

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  sharingUrl  = -> Config.get('servicesUrl') + '/share'

  indexingServiceUrl = -> Configuration.get('servicesUrl') + '/indexing'
  sharingPairUrl     = -> indexingServiceUrl() + '/sharingPair'
  objectMetadataUrl  = -> indexingServiceUrl() + '/metadata'
  indexPairUrl       = -> indexingServiceUrl() + '/indexPair'
  addressFunctionUrl = -> indexingServiceUrl() + '/address'

  logger      = Logger.get('SharingApi')

  #
  # HTTP calls for interacting with the /share endpoint of Kryptnostic Services.
  # Author: rbuckheit
  #
  class SharingApi

    # get all incoming shares
    getIncomingShares: ->
      axios(Requests.wrapCredentials({
        url    : sharingUrl() + OBJECT_PATH
        method : 'GET'
      }))
      .then (response) ->
        return response.data

    removeIncomingShares: ->
      throw new Error 'removeIncomingShares() not implemented'

    # share an object
    shareObject: (sharingRequest) ->
      Promise.resolve()
      .then ->
        sharingRequest.validate()

        axios(Requests.wrapCredentials({
          url     : sharingUrl() + OBJECT_PATH + SHARE_PATH
          method  : 'POST'
          headers : _.cloneDeep(DEFAULT_HEADER)
          data    : JSON.stringify(sharingRequest)
        }))
      .then (response) ->
        logger.debug('shareObject', response.data.data)

    # revoke access to an object
    revokeObject: (revocationRequest) ->
      revocationRequest.validate()

      axios(Requests.wrapCredentials({
        url     : sharingUrl() + OBJECT_PATH + REVOKE_PATH
        method  : 'POST'
        headers : _.cloneDeep(DEFAULT_HEADER)
        data    : JSON.stringify(revocationRequest)
      }))
      .then (response) ->
        logger.debug('revokeObject', response.data.data)

    # register keys
    registerKeys: (keyRegistrationRequest) ->
      keyRegistrationRequest.validate()

      axios(Requests.wrapCredentials({
        url     : sharingUrl() + KEYS_PATH
        method  : 'POST'
        headers : _.cloneDeep(DEFAULT_HEADER)
        data    : JSON.stringify(keyRegistrationRequest)
      }))
      .then (response) ->
        logger.debug('registerKeys', response)
        return response.data

    getObjectIndexPair: (objectId) ->
      Requests
        .getAsUint8FromUrl(sharingPairUrl() + '/' + objectId)
        .then (response) ->
          return response

    addIndexPair: (objectId, objectIndexPair) ->
      requestData = {}
      requestData[objectId] = btoa(objectIndexPair)
      axios(
        Requests.wrapCredentials({
          url     : sharingUrl() + KEYS_PATH
          method  : 'PUT'
          headers : _.cloneDeep(DEFAULT_HEADER)
          data    : JSON.stringify(requestData)
        })
      )
      .then (response) ->
        log.debug('SharingApi.addIndexPairs()', response)

  return SharingApi
