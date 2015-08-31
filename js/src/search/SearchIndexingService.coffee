define 'kryptnostic.search-indexing-service', [
  'require'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.logger'
  'kryptnostic.metadata-api'
  'kryptnostic.metadata-request'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.search-key-serializer'
  'kryptnostic.search.indexer'
  'kryptnostic.search.metadata-mapper'
  'kryptnostic.sharing-client'
  'kryptnostic.document-search-key-api'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  MetadataApi           = require 'kryptnostic.metadata-api'
  SharingClient         = require 'kryptnostic.sharing-client'
  ObjectIndexer         = require 'kryptnostic.search.indexer'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  MetadataRequest       = require 'kryptnostic.metadata-request'
  JsonChunkingStrategy  = require 'kryptnostic.chunking.strategy.json'
  MetadataMapper        = require 'kryptnostic.search.metadata-mapper'
  SearchKeySerializer   = require 'kryptnostic.search-key-serializer'
  DocumentSearchKeyApi  = require 'kryptnostic.document-search-key-api'

  log = Logger.get('SearchIndexingService')

  #
  # Handles indexing and submission of indexed metadata for StorageRequests.
  # Author: rbuckheit
  #
  class SearchIndexingService

    constructor : ->
      @kryptnosticEngine    = new MockKryptnosticEngine()
      @metadataMapper       = new MetadataMapper()
      @metadataApi          = new MetadataApi()
      @objectIndexer        = new ObjectIndexer()
      @sharingClient        = new SharingClient()
      @searchKeySerializer  = new SearchKeySerializer()
      @documentSearchKeyApi = new DocumentSearchKeyApi()

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
      .then ({ _objectAddressFunction, _objectSearchKey, _objectConversionMatrix }) ->
        objectAddressFunction  = _objectAddressFunction
        objectSearchKey        = _objectSearchKey
        objectConversionMatrix = _objectConversionMatrix
      .then =>
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
          kryptnosticObject.encrypt(cryptoService)
          kryptnosticObject.validateEncrypted()

          # format request
          data = kryptnosticObject.data
          indexedMetadata = new IndexedMetadata { key, data , id }
          metadataIndex.push(indexedMetadata)

        return new MetadataRequest { metadata : metadataIndex }

  return SearchIndexingService
