define 'kryptnostic.metadata-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Promise = require 'bluebird'

  log = Logger.get('MetadataApi')

  #
  # HTTP calls for submitting indexed object metadata.
  # Author: rbuckheit
  #
  class MetadataApi

    uploadMetadata: (metadataRequest) ->
      log.warn('metadata api not implemented!', { metadataRequest })
      return Promise.resolve()

  return MetadataApi
