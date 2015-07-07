define 'soteria.object-api', [
  'require'
  'jquery'
  'soteria.security-utils'
  'soteria.kryptnostic-object'
  'soteria.logger'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'soteria.security-utils'
  KryptnosticObject = require 'soteria.kryptnostic-object'
  Logger            = require 'soteria.logger'

  OBJECT_URL        = 'http://localhost:8081/v1/object'
  TYPE_PATH         = '/type'

  logger            = Logger.get('ObjectApi')

  validateId = (id) ->
    if !id
      throw new Error('missing or empty id')

  validateType = (type) ->
    if !type
      throw new Error('missing or empty object type')
  #
  # HTTP calls for interacting with the /object endpoint of Kryptnostic Services.
  # Author: rbuckheit
  #
  class ObjectApi

    # get all object ids accessible to the user
    getObjectIds : ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL
        type : 'GET'
      }))
      .then (response) ->
        return response.data

    # load a kryptnosticObject in encrypted form
    getObject : (id) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id
        type : 'GET'
      }))
      .then (data) ->
        return KryptnosticObject.createFromEncrypted(data)

    # get all object ids of a particular type
    getObjectIdsByType: (type) ->
      validateType(type)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + TYPE_PATH + '/' + type
        type : 'GET'
      }))
      .then (response) ->
        return response.data

    # create a pending object for a new object and return an id
    createPendingObject : (pendingRequest) ->
      pendingRequest.validate()

      jquery.ajax(SecurityUtils.wrapRequest({
        url         : OBJECT_URL + '/'
        type        : 'PUT'
        contentType : 'application/json'
        data        : JSON.stringify(pendingRequest)
      }))
      .then (response) ->
        logger.debug('created pending', response)
        return response.data

    # create a pending object for an object which already exists
    createPendingObjectFromExisting : (id) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id
        type : 'PUT'
      }))
      .then (response) ->
        logger.debug('created pending from existing', response)
        return response.data

    # adds an encrypted block to a pending object
    updateObject : (id, encryptableBlock) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url         : OBJECT_URL + '/' + id
        type        : 'POST'
        contentType : 'application/json'
        data        : JSON.stringify(encryptableBlock)
      }))
      .then (response) ->
        logger.debug('submitted block', response)

  return ObjectApi
