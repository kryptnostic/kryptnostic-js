define 'kryptnostic.search-api', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  Logger           = require 'kryptnostic.logger'
  Requests         = require 'kryptnostic.requests'
  Configuration    = require 'kryptnostic.configuration'

  searchServiceUrl = -> Configuration.get('servicesUrl') + '/search/fast'

  log = Logger.get('SearchApi')

  #
  # HTTP calls for submitting encrypted search queries to the server.
  # Author: rbuckheit
  #
  class SearchApi

    # returns a list of encrypted indexMetadata for matches.
    search: (encryptedToken) ->
      return Requests.postUint8ToUrl(searchServiceUrl(), encryptedToken)
      .then (response) ->
        log.info('searched')
        return response.data

  return SearchApi
