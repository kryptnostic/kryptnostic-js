define 'kryptnostic.search-indexing-service', [
  'require'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.logger'
  'kryptnostic.metadata-api'
  'kryptnostic.metadata-request'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.search.indexer'
  'kryptnostic.search.metadata-mapper'
  'kryptnostic.sharing-client'
  'kryptnostic.encrypted-search-object-key'
  'kryptnostic.encrypted-search-bridge-key'
], (require) ->

  Logger                   = require 'kryptnostic.logger'
  MetadataApi              = require 'kryptnostic.metadata-api'
  SharingClient            = require 'kryptnostic.sharing-client'
  ObjectIndexer            = require 'kryptnostic.search.indexer'
  MockKryptnosticEngine    = require 'kryptnostic.mock.kryptnostic-engine'
  MetadataRequest          = require 'kryptnostic.metadata-request'
  JsonChunkingStrategy     = require 'kryptnostic.chunking.strategy.json'
  MetadataMapper           = require 'kryptnostic.search.metadata-mapper'
  EncryptedSearchBridgeKey = require 'kryptnostic.encrypted-search-bridge-key'
  EncryptedSearchObjectKey = require 'kryptnostic.encrypted-search-object-key'

  log = Logger.get('SearchIndexingService')

  #
  # Handles indexing and submission of indexed metadata for StorageRequests.
  # Author: rbuckheit
  #
  class SearchIndexingService

    constructor : ->
      @fheEngine      = new MockKryptnosticEngine()
      @metadataMapper = new MetadataMapper()
      @metadataApi    = new MetadataApi()
      @objectIndexer  = new ObjectIndexer()
      @sharingClient  = new SharingClient()

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
      bridgeKey = @fheEngine.getBridgeKey({ sharingKey })
      key = EncryptedSearchBridgeKey.create(bridgeKey)
      encryptedSearchObjectKey = new EncryptedSearchObjectKey { id, key }
      @sharingClient.registerSearchKeys([ encryptedSearchObjectKey ])

  return SearchIndexingService
