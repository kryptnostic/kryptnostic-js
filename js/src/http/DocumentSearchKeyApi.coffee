define 'kryptnostic.document-search-key-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Promise = require 'bluebird'

  indexingServiceUrl = -> Configuration.get('servicesUrl') + "/indexing";
  sharingPairUrl     = -> indexingServiceUrl() + "/share";
  addressFunctionUrl = -> indexingServiceUrl() + "/address";

  log = Logger.get('DocumentSearchKeyApi')

  #
  # HTTP calls for submitting document address functions, search keys, and conversion matrices.
  # Author: rbuckheit
  #
  class DocumentSearchKeyApi

    # input: uint8 representation of addres matrix, encrypted and serialized by SearchKeySerializer.
    uploadAddressFunction: (id, uint8) ->
      Requests.postToUrl(addressFunctionUrl() + '/' + id, uint8)
      .then (response) ->
        log.info('uploadAddressFunction', { id } )
        return response.data

    uploadSharingPair: (id, { objectSearchKey, objectConversionMatrix }) ->
      Requests.postToUrl(sharingPairUrl() + '/' + id, objectSearchKey + objectConversionMatrix)
      .then (response) ->
        log.info('uploadSharingPair', { id } )
        return response.data

  return DocumentSearchKeyApi
