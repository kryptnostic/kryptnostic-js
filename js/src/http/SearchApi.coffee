define 'kryptnostic.search-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  Logger           = require 'kryptnostic.logger'
  Requests         = require 'kryptnostic.requests'
  Configuration    = require 'kryptnostic.configuration'

  searchServiceUrl = -> Configuration.get('servicesUrl') + '/search'

  logger = Logger.get('SearchApi')

  #
  # HTTP calls for submitting encrypted search queries to the server.
  # Author: rbuckheit
  #
  class SearchApi

    # returns a list of encrypted indexMetadata for matches.
    search: (searchRequest) ->
      return Requests.postUint8ToUrl(
        searchServiceUrl(),
        searchRequest
      )
      .then (response) ->
        logger.info('searched')
        return response.data

  return SearchApi
