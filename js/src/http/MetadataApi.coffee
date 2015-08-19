define 'kryptnostic.metadata-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
], (require) ->

  axios         = require 'axios'
  Configuration = require 'kryptnostic.configuration'

  metadataUrl = -> Configuration.get('servicesUrl') + '/metadata'

  #
  # HTTP calls for submitting indexed object metadata.
  # Author: rbuckheit
  #
  class MetadataApi

    register: ({ metadataRequest }) ->
      Promise.resolve()
      .then ->
        metadataRequest.validate()
      .then ->
        Promise.resolve(axios({
          method : 'POST'
          data   : JSON.stringify( metadataRequest )
          url    : metadataUrl()
        }))

  return MetadataApi
