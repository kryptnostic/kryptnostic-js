define 'kryptnostic.object-search-key-api', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.configuration'
], (require) ->

  Logger  = require 'kryptnostic.logger'

  indexingServiceUrl = -> Configuration.get('servicesUrl') + '/indexing'
  sharingPairUrl     = -> indexingServiceUrl() + '/share'
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

  return ObjectSearchKeyApi
