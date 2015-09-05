define 'kryptnostic.object-search-key-api', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Requests = require 'kryptnostic.requests'
  Configuration = require 'kryptnostic.configuration'

  indexingServiceUrl = -> Configuration.get('servicesUrl') + '/indexing'
  sharingPairUrl     = -> indexingServiceUrl() + '/sharingPair'
  objectMetadataUrl  = -> indexingServiceUrl() + '/metadata'
  indexPairUrl       = -> indexingServiceUrl() + '/indexPair'
  addressFunctionUrl = -> indexingServiceUrl() + '/address'

  log = Logger.get('ObjectSearchKeyApi')

  #
  # HTTP calls for submitting object address functions, search keys, and conversion matrices.
  # Author: rbuckheit
  #
  class ObjectSearchKeyApi

    # input: uint8 representation of addres matrix, encrypted and serialized by SearchKeySerializer.
    uploadAddressFunction: ( id, uint8 ) ->
      Requests.postToUrl(addressFunctionUrl() + '/' + id, uint8)
      .then (response) ->
        log.info('uploadAddressFunction', { id } )
        return response.data

    uploadSharingPair: ( id, sharingPairBlob ) ->
      Requests.postToUrl(sharingPairUrl() + '/' + id, sharingPairBlob )
      .then (response) ->
        log.info('uploadSharingPair', { id } )
        return response.data

    getIndexPair: ( id ) ->
      return Requests.getAsUint8FromUrl(sharingPairUrl() + '/' + id)

  return ObjectSearchKeyApi
