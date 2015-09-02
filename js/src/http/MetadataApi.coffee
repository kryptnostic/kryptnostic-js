define 'kryptnostic.metadata-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Promise = require 'bluebird'

  metadataUrl = -> Configuration.get('servicesUrl') + "/indexing/metadata";

  log = Logger.get('MetadataApi')

  #
  # HTTP calls for submitting indexed object metadata.
  # Author: rbuckheit
  #
  class MetadataApi

    uploadMetadata: (metadataRequest) ->
      return Promise.resolve()

  return MetadataApi
