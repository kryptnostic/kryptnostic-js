define 'kryptnostic.search-indexing-service', [
  'require'
  'bluebird'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.crypto-service-loader'
  'kryptnostic.kryptnostic-object'
  'kryptnostic.logger'
  'kryptnostic.metadata-api'
  'kryptnostic.metadata-request'
  'kryptnostic.object-api'
  'kryptnostic.kryptnostic-engine'
  'kryptnostic.search.indexer'
  'kryptnostic.search.metadata-mapper'
  'kryptnostic.indexed-metadata'
  'kryptnostic.kryptnostic-engine-provider'
  'kryptnostic.sharing-api'
], (require) ->

  # libraries
  Promise = require 'bluebird'

  # kryptnostic
  CryptoServiceLoader       = require 'kryptnostic.crypto-service-loader'
  IndexedMetadata           = require 'kryptnostic.indexed-metadata'
  JsonChunkingStrategy      = require 'kryptnostic.chunking.strategy.json'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'
  KryptnosticObject         = require 'kryptnostic.kryptnostic-object'
  MetadataMapper            = require 'kryptnostic.search.metadata-mapper'
  MetadataRequest           = require 'kryptnostic.metadata-request'
  ObjectIndexer             = require 'kryptnostic.search.indexer'

  # APIs
  MetadataApi               = require 'kryptnostic.metadata-api'
  ObjectApi                 = require 'kryptnostic.object-api'
  SharingApi                = require 'kryptnostic.sharing-api'

  # utils
  Logger = require 'kryptnostic.logger'

  log = Logger.get('SearchIndexingService')

  #
  # Handles indexing and submission of indexed metadata for StorageRequests
  #
  class SearchIndexingService

    constructor : ->
      @cryptoServiceLoader  = new CryptoServiceLoader()
      @metadataApi          = new MetadataApi()
      @objectApi            = new ObjectApi()
      @sharingApi           = new SharingApi()
      @metadataMapper       = new MetadataMapper()
      @objectIndexer        = new ObjectIndexer()

    # indexes and uploads the submitted object.
    submit: (storageRequest, objectKey, parentObjectKey, objectSearchPair) ->

      unless storageRequest.isSearchable
        log.info('skipping non-searchable object')
        return Promise.resolve()

      { body } = storageRequest
      { objectIndexPair } = {}

      parentObjectId = if parentObjectKey? then parentObjectKey.objectId else objectKey.objectId

      Promise.resolve()
      .then =>
        engine = KryptnosticEngineProvider.getEngine()
        if not objectSearchPair?
          objectIndexPair  = engine.generateObjectIndexPair()
          objectSearchPair = engine.calculateObjectSearchPairFromObjectIndexPair(objectIndexPair)
          @sharingApi.addObjectSearchPair(parentObjectId, objectSearchPair)
        else
          objectIndexPair = engine.calculateObjectIndexPairFromObjectSearchPair(objectSearchPair)

        Promise.resolve()
        .then =>
          @objectIndexer.index(parentObjectId, body)
        .then (metadata) =>
          @prepareMetadataRequest({ objectKey, parentObjectKey, metadata, objectIndexPair })
        .then (metadataRequest) =>
          @metadataApi.uploadMetadata( metadataRequest )
        .then ->
          return objectSearchPair

    # currently produces a single request, batch later if needed.
    prepareMetadataRequest: ({ objectKey, parentObjectKey, metadata, objectIndexPair }) ->

      parentObjectId = if parentObjectKey? then parentObjectKey.objectId else objectKey.objectId

      Promise.resolve(
        @objectApi.getLatestVersionedObjectKey(parentObjectId)
      )
      .then (versionedObjectKey) =>
        @cryptoServiceLoader.getObjectCryptoServiceV2(
          versionedObjectKey,
          { expectMiss : false }
        )
      .then (cryptoService) =>
        keyedMetadata = @metadataMapper.mapToKeys({ metadata, objectIndexPair })

        metadataIndex = []
        for key, metadata of keyedMetadata

          # encrypt metadata
          kryptnosticObject = KryptnosticObject.createFromDecrypted({
            id: objectKey.objectId,
            body: metadata
          })
          kryptnosticObject.setChunkingStrategy(JsonChunkingStrategy.URI)
          encrypted = kryptnosticObject.encrypt(cryptoService)
          encrypted.validateEncrypted()

          # format request
          data = encrypted.body
          _.extend(
            data,
            {
              key: objectKey.objectId,
              strategy: { '@class': JsonChunkingStrategy.URI }
            }
          )

          indexedMetadata = new IndexedMetadata({
            key: key,
            data: data,
            id: parentObjectId
          })
          metadataIndex.push(indexedMetadata)

        return new MetadataRequest { metadata : metadataIndex }

  return SearchIndexingService
