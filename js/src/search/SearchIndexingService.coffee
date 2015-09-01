define 'kryptnostic.search-indexing-service', [
  'require'
  'bluebird'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.document-search-key-api'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.logger'
  'kryptnostic.metadata-api'
  'kryptnostic.metadata-request'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.search-key-serializer'
  'kryptnostic.search.indexer'
  'kryptnostic.search.metadata-mapper'
  'kryptnostic.sharing-client'
  'kryptnostic.indexed-metadata'
], (require) ->

  Promise               = require 'bluebird'

  BinaryUtils           = require 'kryptnostic.binary-utils'
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  DocumentSearchKeyApi  = require 'kryptnostic.document-search-key-api'
  IndexedMetadata       = require 'kryptnostic.indexed-metadata'
  JsonChunkingStrategy  = require 'kryptnostic.chunking.strategy.json'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  Logger                = require 'kryptnostic.logger'
  MetadataApi           = require 'kryptnostic.metadata-api'
  MetadataMapper        = require 'kryptnostic.search.metadata-mapper'
  MetadataRequest       = require 'kryptnostic.metadata-request'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  ObjectIndexer         = require 'kryptnostic.search.indexer'
  SearchKeySerializer   = require 'kryptnostic.search-key-serializer'
  SharingClient         = require 'kryptnostic.sharing-client'

  log = Logger.get('SearchIndexingService')

  #
  # Handles indexing and submission of indexed metadata for StorageRequests.
  # Author: rbuckheit
  #
  class SearchIndexingService

    constructor : ->
      @cryptoServiceLoader  = new CryptoServiceLoader()
      @documentSearchKeyApi = new DocumentSearchKeyApi()
      @kryptnosticEngine    = new MockKryptnosticEngine()
      @metadataApi          = new MetadataApi()
      @metadataMapper       = new MetadataMapper()
      @objectIndexer        = new ObjectIndexer()
      @searchKeySerializer  = new SearchKeySerializer()
      @sharingClient        = new SharingClient()

    # indexes and uploads the submitted object.
    submit: ({ id, storageRequest }) ->
      unless storageRequest.isSearchable
        log.info('skipping non-searchable object', { id })
        return Promise.resolve()

      { body } = storageRequest
      { objectAddressFunction, objectSearchKey, objectConversionMatrix } = {}

      uintId = BinaryUtils.stringToUint8(id)

      Promise.props({
        _objectAddressFunction  : @kryptnosticEngine.getObjectAddressFunction(uintId)
        _objectSearchKey        : @kryptnosticEngine.getObjectSearchKey(uintId)
        _objectConversionMatrix : @kryptnosticEngine.getObjectConversionMatrix(uintId)
      })
      .then ({ _objectAddressFunction, _objectSearchKey, _objectConversionMatrix }) =>
        objectAddressFunction  = _objectAddressFunction
        objectSearchKey        = _objectSearchKey
        objectConversionMatrix = _objectConversionMatrix

        encryptedAddressFunction = @searchKeySerializer.encrypt(objectAddressFunction)
        @documentSearchKeyApi.uploadAddressFunction(id, encryptedAddressFunction)
      .then =>
        @documentSearchKeyApi.uploadSharingPair(id, { objectSearchKey, objectConversionMatrix })
      .then =>
        @objectIndexer.index(id, body)
      .then (metadata) =>
        @prepareMetadataRequest({ id, metadata, objectAddressFunction, objectSearchKey })
      .then (metadataRequest) =>
        @metadataApi.uploadMetadata( metadataRequest )

    # currently produces a single request, batch later if needed.
    prepareMetadataRequest: ({ id, metadata, objectAddressFunction, objectSearchKey }) ->
      Promise.resolve()
      .then =>
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss : false })
      .then (cryptoService) =>
        keyedMetadata = @metadataMapper.mapToKeys({
          metadata, objectAddressFunction, objectSearchKey
        })

        metadataIndex = []
        for key, metadata of keyedMetadata
          body = metadata

          # encrypt metadata
          kryptnosticObject = KryptnosticObject.createFromDecrypted({ id, body })
          kryptnosticObject.setChunkingStrategy(JsonChunkingStrategy.URI)
          encrypted = kryptnosticObject.encrypt(cryptoService)
          encrypted.validateEncrypted()

          # format request
          data = encrypted.body
          _.extend(data, { key: id, strategy: { '@class': JsonChunkingStrategy.URI } })
          indexedMetadata = new IndexedMetadata { key, data , id }
          metadataIndex.push(indexedMetadata)

        return new MetadataRequest { metadata : metadataIndex }

  return SearchIndexingService
