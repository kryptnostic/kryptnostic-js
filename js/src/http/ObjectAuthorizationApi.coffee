define 'kryptnostic.object-authorization-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.object-metadata'
  'kryptnostic.validators'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  Config   = require 'kryptnostic.configuration'
  Logger   = require 'kryptnostic.logger'
  Requests = require 'kryptnostic.requests'

  # constants
  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  accessUrl  = -> Config.get('servicesUrlV2') + '/access'
  ownersUrl  = (objectId) -> accessUrl() + '/owners/' + objectId
  readersUrl = (objectId) -> accessUrl() + '/readers/' + objectId
  writersUrl = (objectId) -> accessUrl() + '/writers/' + objectId

  logger = Logger.get('ObjectAuthorizationApi')

  class ObjectAuthorizationApi

    wrapCredentials : (request, credentials) ->
      return Requests.wrapCredentials(request, credentials)

    getUsersWithOwnerAccess: (objectId) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'GET'
            url    : ownersUrl(objectId)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Iterable<java.util.UUID>
          return axiosResponse.data
        else
          return null

    getUsersWithReadAccess: (objectId) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'GET'
            url    : readersUrl(objectId)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Iterable<java.util.UUID>
          return axiosResponse.data
        else
          return null

    getUsersWithWriteAccess: (objectId) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            method : 'GET'
            url    : writersUrl(objectId)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == Iterable<java.util.UUID>
          return axiosResponse.data
        else
          return null

  return ObjectAuthorizationApi