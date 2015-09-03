define 'kryptnostic.search-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Promise = require 'bluebird'

  log = Logger.get('SearchApi')

  #
  # HTTP calls for submitting encrypted search queries to the server.
  # Author: rbuckheit
  #
  class SearchApi

    # returns a list of encrypted indexMetadata for matches.
    search: (encryptedToken) ->
      log.warn('search api not implemented!')
      return Promise.resolve([])

  return SearchApi
