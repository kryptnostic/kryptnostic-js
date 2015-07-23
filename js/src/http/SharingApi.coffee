define 'kryptnostic.sharing-api', [
  'require'
  'jquery'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.security-utils'
  'kryptnostic.logger'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'kryptnostic.security-utils'
  Logger            = require 'kryptnostic.logger'
  Config            = require 'kryptnostic.configuration'
  Promise           = require 'bluebird'

  sharingUrl        = -> Config.get('servicesUrl') + '/share'

  TYPE_PATH         = '/type'
  SHARE_PATH        = '/share'
  REVOKE_PATH       = '/revoke'
  OBJECT_PATH       = '/object'
  KEYS_PATH         = '/keys'

  logger            = Logger.get('SharingApi')

  #
  # HTTP calls for interacting with the /share endpoint of Kryptnostic Services.
  # Author: rbuckheit
  #
  class SharingApi

    # get all incoming shares
    getIncomingShares : ->
      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : sharingUrl() + OBJECT_PATH
        type : 'GET'
      })))
      .then (data) ->
        return data

    # share an object
    shareObject: (sharingRequest) ->
      sharingRequest.validate()

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : sharingUrl() + OBJECT_PATH + SHARE_PATH
        type        : 'POST'
        contentType : 'application/json'
        data        : JSON.stringify(sharingRequest)
      })))
      .then (response) ->
        logger.debug('shareObject', response)
        return response.data

    # revoke access to an object
    revokeObject: (revocationRequest) ->
      revocationRequest.validate()

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : sharingUrl() + OBJECT_PATH + REVOKE_PATH
        type        : 'POST'
        contentType : 'application/json'
        data        : JSON.stringify(revocationRequest)
      })))
      .then (response) ->
        logger.debug('revokeObject', response)
        return response.data

    # register keys
    registerKeys: (keyRegistrationRequest) ->
      keyRegistrationRequest.validate()

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : sharingUrl() + KEYS_PATH
        type        : 'POST'
        contentType : 'application/json'
        data        : JSON.stringify(keyRegistrationRequest)
      })))
      .then (response) ->
        logger.debug('registerKeys', response)
        return response.data

    # register search keys
    registerSearchKeys: (encryptedSearchObjectKeys) ->
      throw new Error 'unimplemented'

  return SharingApi
