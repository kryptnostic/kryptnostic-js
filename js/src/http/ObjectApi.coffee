define 'soteria.object-api', [
  'require'
  'jquery'
  'soteria.security-utils'
  'soteria.kryptnostic-object'
], (require) ->

  jquery            = require 'jquery'
  SecurityUtils     = require 'soteria.security-utils'
  KryptnosticObject = require 'soteria.kryptnostic-object'

  OBJECT_URL    = 'http://localhost:8081/v1/object'

  log = (message, args...) ->
    console.info("[ObjectApi] #{message} #{args.map(JSON.stringify)}")

  validateId = (id) ->
    unless !!id
      throw new Error('cannot submit block without an id!')

  #
  # HTTP calls for interacting with the /object endpoint of Kryptnostic Services.
  # Author: rbuckheit
  #
  class ObjectApi

    # get all object ids accessible to the user
    getObjectIds : () ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL
        type : 'GET'
      }))
      .then (data) ->
        return data.data

    # load a kryptnosticObject in encrypted form
    getObject : (id) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id
        type : 'GET'
      }))
      .then (data) ->
        return KryptnosticObject.createFromEncrypted(data);

    # create a pending object for a new object and return an id
    createPendingObject : (pendingRequest) ->
      pendingRequest.validate()

      jquery.ajax(SecurityUtils.wrapRequest({
        url         : OBJECT_URL + '/'
        type        : 'PUT'
        contentType : 'application/json',
        data        : JSON.stringify(pendingRequest)
      }))
      .then (response) ->
        log('created pending', response)
        return response.data

    # create a pending object for an object which already exists
    createPendingObjectFromExisting : (id) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id
        type : 'PUT'
      }))
      .then (response) ->
        log('created pending from existing', response);
        return response.data

    # adds an encrypted block to a pending object
    updateObject : (id, encryptableBlock) ->
      validateId(id)

      jquery.ajax(SecurityUtils.wrapRequest({
        url         : OBJECT_URL + '/' + id
        type        : 'POST'
        contentType : 'application/json',
        data        : JSON.stringify(encryptableBlock)
      }))
      .then (response) ->
        log('submitted block', response)
