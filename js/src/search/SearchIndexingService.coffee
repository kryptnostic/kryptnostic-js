define 'kryptnostic.search-indexing-service', [
  'require'
  'bluebird'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.logger'
  'kryptnostic.metadata-api'
  'kryptnostic.metadata-request'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.search.indexer'
  'kryptnostic.search.metadata-mapper'
  'kryptnostic.indexed-metadata'
], (require) ->

  # libraries
  Promise               = require 'bluebird'

  # Kryptnostic apis
  MetadataApi           = require 'kryptnostic.metadata-api'
  SharingApi            = require 'kryptnostic.sharing-api'

  # Kryptnostic classes
  JsonChunkingStrategy  = require 'kryptnostic.chunking.strategy.json'
  CryptoServiceLoader   = require 'kryptnostic.crypto-service-loader'
  IndexedMetadata       = require 'kryptnostic.indexed-metadata'
  KryptnosticObject     = require 'kryptnostic.kryptnostic-object'
  MetadataRequest       = require 'kryptnostic.metadata-request'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  ObjectIndexer         = require 'kryptnostic.search.indexer'
  MetadataMapper        = require 'kryptnostic.search.metadata-mapper'

  # Kryptnostic utils
  Logger                = require 'kryptnostic.logger'

  log = Logger.get('SearchIndexingService')

  #
  # Handles indexing and submission of indexed metadata for StorageRequests.
  # Author: rbuckheit
  #
  class SearchIndexingService

    constructor : ->
      @cryptoServiceLoader = new CryptoServiceLoader()
      @sharingApi          = new SharingApi()
      @engine              = new MockKryptnosticEngine()
      @metadataApi         = new MetadataApi()
      @metadataMapper      = new MetadataMapper()
      @objectIndexer       = new ObjectIndexer()

    # indexes and uploads the submitted object.
    submit: ({ id, storageRequest }) ->
      unless storageRequest.isSearchable
        log.info('skipping non-searchable object', { id })
        return Promise.resolve()

      { body } = storageRequest
      { objectAddressMatrix, objectSearchKey, objectIndexPair } = {}

      Promise.resolve()
      .then =>
        objectAddressMatrix = @engine.getObjectAddressMatrix()
        objectSearchKey     = @engine.getObjectSearchKey()
        objectIndexPair     = @engine.getObjectIndexPair({ objectSearchKey, objectAddressMatrix })
        @sharingApi.addObjectIndexPair(id, objectIndexPair)
      .then =>
        @objectIndexer.index(id, body)
      .then (metadata) =>
        @prepareMetadataRequest({ id, metadata, objectAddressMatrix, objectSearchKey })
      .then (metadataRequest) =>
        @metadataApi.uploadMetadata( metadataRequest )

    # currently produces a single request, batch later if needed.
    prepareMetadataRequest: ({ id, metadata, objectAddressMatrix, objectSearchKey }) ->
      Promise.resolve()
      .then =>
        @cryptoServiceLoader.getObjectCryptoService(id, { expectMiss : false })
      .then (cryptoService) =>
        keyedMetadata = @metadataMapper.mapToKeys({
          metadata, objectAddressMatrix, objectSearchKey
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
