define 'kryptnostic.search-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # utils
  Configuration = require 'kryptnostic.configuration'
  Logger        = require 'kryptnostic.logger'
  Requests      = require 'kryptnostic.requests'
  Validators    = require 'kryptnostic.validators'

  # constants
  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  { validateVersionedObjectKey } = Validators

  searchUrl       = -> Configuration.get('servicesUrlV2') + '/search'
  segmentRangeUrl = (objectId, count) -> searchUrl() + '/' + objectId + '/' + count

  logger = Logger.get('SearchApi')

  #
  # HTTP calls for submitting encrypted search queries to the server.
  #
  class SearchApi

    search: (searchRequest) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : searchUrl(),
            data    : searchRequest,
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == java.util.Map<com.kryptnostic.v2.storage.models.VersionedObjectKey, java.util.Set<java.util.UUID>>
          return axiosResponse.data
        else
          return null
      .catch (e) ->
        return null

    # returns start of range
    @reserveSegmentRange: (objectKey, count) ->

      if not validateVersionedObjectKey(objectKey)
        return Promise.resolve(null)

      if not _.isFinite(count) or count < 0
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method  : 'POST',
            url     : segmentRangeUrl(objectKey.objectId, count),
            headers : DEFAULT_HEADERS
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == integer
          return axiosResponse.data
        else
          return null
      .catch (e) ->
        return null

  return SearchApi
