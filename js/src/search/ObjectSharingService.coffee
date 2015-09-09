define 'kryptnostic.object-sharing-service', [
  'require'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.directory-api'
  'kryptnostic.document-search-key-api'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.rsa-crypto-service'
  'kryptnostic.search-key-serializer'
  'kryptnostic.validators'
], (require) ->
  'use strict'

  Promise               = require 'bluebird'
  DirectoryApi          = require 'kryptnostic.directory-api'
  DocumentSearchKeyApi  = require 'kryptnostic.document-search-key-api'
  Logger                = require 'kryptnostic.logger'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  RsaCryptoService      = require 'kryptnostic.rsa-crypto-service'
  SearchKeySerializer   = require 'kryptnostic.search-key-serializer'
  Validators            = require 'kryptnostic.validators'

  log = Logger.get('ObjectSharingService')

  { validateId, validateUuid } = Validators

  class ObjectSharingService

    constructor: ->
      @engine               = new MockKryptnosticEngine()
      @directoryApi         = new DirectoryApi()
      @documentSearchKeyApi = new DocumentSearchKeyApi()
      @searchKeySerializer  = new SearchKeySerializer()

    shareObject: (objectId, rsaPublicKey) ->

      validateId(objectId)

      Promise.resolve()
        .then =>
          @documentSearchKeyApi.getIndexPair(objectId)
        .then (objectIndexPair) =>
          @createObjectSharingPair(rsaPublicKey, objectIndexPair)
        .then (objectSharingPair) =>
          @documentSearchKeyApi.uploadSharingPair(objectId, objectSharingPair)
        .catch (e) ->
          log.error('sharing object failed')
          log.error(e)

    #
    # helpers (should be private, but can't figure out how to test them if they are...)
    #

    createObjectSharingPair: (rsaPublicKey, objectIndexPair) =>
      objectSharingPair = @engine.getObjectSharingPair({ objectIndexPair })
      rsaCryptoService = new RsaCryptoService({ rsaPublicKey })
      # DOIT - refactor SearchKeySerializer and its encryption logic into a more generic class
      return @searchKeySerializer.encryptWithRsaCryptoService(objectSharingPair, rsaCryptoService)

  return ObjectSharingService
