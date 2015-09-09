define 'kryptnostic.metadata-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.requests'
  'kryptnostic.logger'
], (require) ->

  # libraries
  axios    = require 'axios'
  Promise  = require 'bluebird'

  # Kryptnostic utils
  Config   = require 'kryptnostic.configuration'
  Logger   = require 'kryptnostic.logger'
  Requests = require 'kryptnostic.requests'

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  metadataUrl = -> Config.get('servicesUrl') + '/metadata'
  deleteUrl   = -> metadataUrl() + '/delete'

  log = Logger.get('MetadataApi')

  #
  # HTTP calls for submitting indexed object metadata.
  # Author: rbuckheit
  #
  class MetadataApi

    uploadMetadata: (metadataRequest) ->
      Promise.resolve()
      .then ->
        metadataRequest.validate()
        axios(
          Requests.wrapCredentials({
            url     : metadataUrl()
            method  : 'POST'
            headers : DEFAULT_HEADER
            data    : JSON.stringify(sharingRequest)
          })
        )
      .then (response) ->
        logger.debug('uploadMetadata()', response.data.data)

    deleteAll: (metadataDeleteRequest) ->
      throw new Error 'deleteAll() not implemented'

  return MetadataApi
