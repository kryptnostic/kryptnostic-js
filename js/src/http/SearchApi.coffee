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
  Logger        = require 'kryptnostic.logger'
  Requests      = require 'kryptnostic.requests'
  Configuration = require 'kryptnostic.configuration'

  searchServiceUrl = -> Configuration.get('servicesUrl') + '/search'

  logger = Logger.get('SearchApi')

  #
  # HTTP calls for submitting encrypted search queries to the server.
  #
  class SearchApi

    search: (searchRequest) ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            url    : searchServiceUrl()
            method : 'POST'
            data   : searchRequest
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          # axiosResponse.data == com.kryptnostic.search.v1.models.response.SearchResultResponse
          return axiosResponse.data
        else
          return null
      .catch (e) ->
        return null

  return SearchApi
