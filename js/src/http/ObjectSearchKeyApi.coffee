define 'kryptnostic.object-search-key-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.requests'
  'kryptnostic.configuration'
], (require) ->

  Logger             = require 'kryptnostic.logger'
  Requests           = require 'kryptnostic.requests'
  Configuration      = require 'kryptnostic.configuration'

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
    uploadAddressMatrix: (objectId, addressMatrixAsUint8Array) ->
      Requests
      .postUint8ToUrl(addressFunctionUrl() + '/' + objectId, addressMatrixAsUint8Array)
      .then (response) ->
        log.info('uploadAddressFunction', { objectId } )
        return response.data

    uploadSharingPair: (objectId, sharingPairAsUint8) ->
      Requests
      .postUint8ToUrl(sharingPairUrl() + '/' + objectId, sharingPairAsUint8)
      .then (response) ->
        log.info('uploadSharingPair', { objectId } )
        return response.data

  return ObjectSearchKeyApi
