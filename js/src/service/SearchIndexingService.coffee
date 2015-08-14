define 'kryptnostic.search-indexing-service', [
  'require'
  'kryptnostic.search.indexer'
  'kryptnostic.mock.fhe-engine'
  'kryptnostic.search.metadata-mapper'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.metadata-request'
  'kryptnostic.metadata-api'
  'kryptnostic.logger'
], (require) ->

  ObjectIndexer        = require 'kryptnostic.search.indexer'
  MockFheEngine        = require 'kryptnostic.mock.fhe-engine'
  PaddedMetadataMapper = require 'kryptnostic.search.metadata-mapper'
  JsonChunkingStrategy = require 'kryptnostic.chunking.strategy.json'
  MetadataRequest      = require 'kryptnostic.metadata-request'
  MetadataApi          = require 'kryptnostic.metadata-api'
  Logger               = require 'kryptnostic.logger'

  log = Logger.get('SearchIndexingService')

  #
  # Handles indexing and submission of indexed metadata for StorageRequests.
  # Author: rbuckheit
  #
  class SearchIndexingService

    constructor : ->
      @fheEngine      = new MockFheEngine()
      @metadataMapper = new PaddedMetadataMapper()
      @metadataApi    = new MetadataApi()
      @objectIndexer  = new ObjectIndexer()

    # indexes and uploads the submitted object.
    submit: ({ id, storageRequest }) ->
      unless storageRequest.isSearchable
        log.info('skipping non-searchable object', { id })
        return Promise.resolve()

      { sharingKey } = {}
      { body } = storageRequest

      Promise.resolve()
      .then =>
        @fheEngine.generateSharingKey({ id })
      .then (_sharingKey) ->
        sharingKey = _sharingKey
      .then =>
        @_submitBridgeKey(id, sharingKey)
      .then =>
        @objectIndexer.index(id, body)
      .then (metadata) =>
        @prepareMetadataRequest({ id, metadata, sharingKey })
      .then (metadataRequest) =>
        @metadataApi.uploadMetadata( metadataRequest )

    # currently produces a single request, batch later if needed.
    prepareMetadataRequest: ({ id, metadata, sharingKey }) ->
      Promise.resolve()
      .then =>
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss : false })
      .then (cryptoService) =>
        keyedMetadata = @metadataMapper.mapToKeys({ metadata, sharingKey })

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

    _submitBridgeKey : (id, sharingKey) ->
      throw new Error 'unimplemented'
