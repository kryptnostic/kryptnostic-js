define 'kryptnostic.sharing-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.binary-utils'
  'kryptnostic.configuration'
  'kryptnostic.logger'
  'kryptnostic.requests'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'
  Config      = require 'kryptnostic.configuration'
  Logger      = require 'kryptnostic.logger'
  Requests    = require 'kryptnostic.requests'

  # constants
  TYPE_PATH   = '/type'
  SHARE_PATH  = '/share'
  REVOKE_PATH = '/revoke'
  OBJECT_PATH = '/object'
  KEYS_PATH   = '/keys'
  OBJECT_KEYS = '/objectKeys'

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  sharingEndpoint         = -> Config.get('servicesUrl') + SHARE_PATH
  shareObjectUrl          = -> sharingEndpoint() + OBJECT_PATH + SHARE_PATH
  revokeObjectUrl         = -> sharingEndpoint() + OBJECT_PATH + REVOKE_PATH
  getIncomingSharesUrl    = -> sharingEndpoint() + OBJECT_PATH
  removeIncomingSharesUrl = (id ) -> sharingEndpoint() + OBJECT_PATH + '/' + id
  addObjectSearchPairUrl  = -> sharingEndpoint() + KEYS_PATH
  getObjectSearchPairUrl  = (id) -> sharingEndpoint() + OBJECT_PATH + '/' + id + OBJECT_KEYS

  logger = Logger.get('SharingApi')

  #
  # HTTP calls for interacting with the /share endpoint of Kryptnostic Services.
  #
  class SharingApi

    # get all incoming shares
    getIncomingShares: ->
      Promise.resolve()
      .then ->
        axios(
          Requests.wrapCredentials({
            url    : getIncomingSharesUrl()
            method : 'GET'
          })
        )
      .then (response) ->
        logger.debug('getIncomingShares()', response)
        return response.data

    removeIncomingShares: ->
      throw new Error 'removeIncomingShares() not implemented'

    # share an object
    shareObject: (sharingRequest) ->
      Promise.resolve()
      .then ->
        sharingRequest.validate()
        axios(
          Requests.wrapCredentials({
            url     : shareObjectUrl()
            method  : 'POST'
            headers : DEFAULT_HEADER
            data    : JSON.stringify(sharingRequest)
          })
        )
      .then (response) ->
        logger.debug('shareObject()', response.data.data)

    # revoke access to an object
    revokeObject: (revocationRequest) ->
      Promise.resolve()
      .then ->
        revocationRequest.validate()
        axios(
          Requests.wrapCredentials({
            url     : revokeObjectUrl()
            method  : 'POST'
            headers : DEFAULT_HEADER
            data    : JSON.stringify(revocationRequest)
          })
        )
      .then (response) ->
        logger.debug('revokeObject()', response.data.data)

    getObjectSearchPair: (objectId) ->
      return Requests.getAsUint8FromUrl(
        getObjectSearchPairUrl(objectId)
      )


    addObjectSearchPair: (objectId, objectSearchPair) ->
      Promise.resolve()
      .then ->
        requestData = {}
        objectSearchPairAsBase64 = BinaryUtils.uint8ToBase64(objectSearchPair)
        requestData[objectId] = {
          indexPair: objectSearchPairAsBase64
        }
        axios(
          Requests.wrapCredentials({
            url     : addObjectSearchPairUrl()
            method  : 'PUT'
            headers : DEFAULT_HEADER
            data    : requestData
          })
        )
      .then (response) ->
        logger.debug('addObjectSearchPair()', response.data)

  return SharingApi
