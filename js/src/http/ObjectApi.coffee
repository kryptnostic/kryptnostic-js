define 'soteria.object-api', [
  'require'
  'jquery'
  'soteria.configuration'
  'soteria.kryptnostic-object'
  'soteria.logger'
  'soteria.security-utils'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'soteria.security-utils'
  KryptnosticObject = require 'soteria.kryptnostic-object'
  Logger            = require 'soteria.logger'
  Config            = require 'soteria.configuration'

  objectUrl         = -> Config.get('servicesUrl') + '/object'

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
        url  : objectUrl()
        type : 'GET'
      }))
      .then (response) ->
        return response.data

    # load a kryptnosticObject in encrypted form
    getObject : (id) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl() + '/' + id
        type : 'GET'
      }))
      .then (data) ->
        return KryptnosticObject.createFromEncrypted(data)

    # get all object ids of a particular type
    getObjectIdsByType: (type) ->
      validateType(type)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl() + '/type/' + type
        type : 'GET'
      }))
      .then (response) ->
        return response.data

    # create a pending object for a new object and return an id
    createPendingObject : (pendingRequest) ->
      pendingRequest.validate()

      jquery.ajax(SecurityUtils.wrapRequest({
        url         : objectUrl() + '/'
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
        url  : objectUrl() + '/' + id
        type : 'PUT'
      }))
      .then (response) ->
        logger.debug('created pending from existing', response)
        return response.data

    # adds an encrypted block to a pending object
    updateObject : (id, encryptableBlock) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url         : objectUrl() + '/' + id
        type        : 'POST'
        contentType : 'application/json'
        data        : JSON.stringify(encryptableBlock)
      }))
      .then (response) ->
        logger.debug('submitted block', response)

  return ObjectApi
