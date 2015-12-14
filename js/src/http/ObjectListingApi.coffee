define 'kryptnostic.object-listing-api', [
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

  objectUrl   = -> Config.get('servicesUrlV2') + '/objects'
  typeNameUrl = (name) -> objectUrl() + '/typename/' + name

  objectIdsByTypeUrl = (userId, typeId) -> objectUrl() + '/' + userId + '/type/' + typeId

  logger = Logger.get('ObjectListingApi')

  class ObjectListingApi

    wrapCredentials : (request, credentials) ->
      return Requests.wrapCredentials(request, credentials)

    getObjectIdsByType: (userId, typeId) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            url    : objectIdsByTypeUrl(userId, typeId)
            method : 'GET'
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == java.util.Set<java.util.UUID>
          return axiosResponse.data
        else
          return null

    getTypeForName: (name) ->
      Promise.resolve(
        axios(
          @wrapCredentials({
            url         : typeNameUrl(name)
            method      : 'GET'
            headers     : _.clone(DEFAULT_HEADER)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == java.util.UUID
          return axiosResponse.data
        else
          return null

  return ObjectListingApi
