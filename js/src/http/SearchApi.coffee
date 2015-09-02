define 'kryptnostic.search-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Promise = require 'bluebird'
  Requests = require 'kryptnostic.requests'

  searchServiceUrl   = -> Configuration.get('servicesUrl') + '/search/fast'

  log = Logger.get('SearchApi')

  #
  # HTTP calls for submitting encrypted search queries to the server.
  # Author: rbuckheit
  #
  class SearchApi

    # returns a list of encrypted indexMetadata for matches.
    search: (encryptedToken) ->
      return Requests.postToUrl(searchServiceUrl(), encryptedToken)
      .then (response) ->
        log.info('searched')
        return response.data

  return SearchApi
