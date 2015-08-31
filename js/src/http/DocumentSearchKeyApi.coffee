define 'kryptnostic.document-search-key-api', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
], (require) ->

  Logger  = require 'kryptnostic.logger'
  Promise = require 'bluebird'

  log = Logger.get('DocumentSearchKeyApi`')

  #
  # HTTP calls for submitting document address functions, search keys, and conversion matrices.
  # Author: rbuckheit
  #
  class DocumentSearchKeyApi

    # input: uint8 representation of addres matrix, encrypted and serialized by SearchKeySerializer.
    uploadAddressFunction: (id, uint8) ->
      log.warn('DocumentSearchKeyApi is not implemented!')
      return Promise.resolve()

    uploadSharingPair: (id, { objectSearchKey, objectConversionMatrix }) ->
      log.warn('DocumentSearchKeyApi is not implemented!')
      return Promise.resolve()

  return DocumentSearchKeyApi
