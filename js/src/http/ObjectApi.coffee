define 'kryptnostic.object-api', [
  'require'
  'jquery'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.logger'
  'kryptnostic.security-utils'
  'kryptnostic.object-metadata'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'kryptnostic.security-utils'
  KryptnosticObject = require 'kryptnostic.kryptnostic-object'
  Logger            = require 'kryptnostic.logger'
  Config            = require 'kryptnostic.configuration'
  Promise           = require 'bluebird'
  ObjectMetadata    = require 'kryptnostic.object-metadata'

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
      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl()
        type : 'GET'
      })))
      .then (response) ->
        return response.data

    # load a kryptnosticObject in encrypted form
    getObject : (id) ->
      validateId(id)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl() + '/' + id
        type : 'GET'
      })))
      .then (data) ->
        return KryptnosticObject.createFromEncrypted(data)

    # load object metadata only without contents
    getObjectMetadata: (id) ->
      validateId(id)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl() + '/' + id + '/metadata'
        type : 'GET'
      })))
      .then (data) ->
        return new ObjectMetadata(data)

    # get all object ids of a particular type
    getObjectIdsByType: (type) ->
      validateType(type)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl() + '/type/' + type
        type : 'GET'
      })))
      .then (response) ->
        return response.data

    # create a pending object for a new object and return an id
    createPendingObject : (pendingRequest) ->
      pendingRequest.validate()

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : objectUrl() + '/'
        type        : 'PUT'
        contentType : 'application/json'
        data        : JSON.stringify(pendingRequest)
      })))
      .then (response) ->
        logger.debug('created pending', response)
        return response.data

    # create a pending object for an object which already exists
    createPendingObjectFromExisting : (id) ->
      validateId(id)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url  : objectUrl() + '/' + id
        type : 'PUT'
      })))
      .then (response) ->
        logger.debug('created pending from existing', response)
        return response.data

    # adds an encrypted block to a pending object
    updateObject : (id, encryptableBlock) ->
      validateId(id)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : objectUrl() + '/' + id
        type        : 'POST'
        contentType : 'application/json'
        data        : JSON.stringify(encryptableBlock)
      })))
      .then (response) ->
        logger.debug('submitted block', response)

    # deletes an object
    deleteObject : (id) ->
      validateId(id)

      Promise.resolve(jquery.ajax(SecurityUtils.wrapRequest({
        url         : objectUrl() + '/' + id
        type        : 'DELETE'
      })))
      .then (response) ->
        logger.debug('deleted object', response)

  return ObjectApi
