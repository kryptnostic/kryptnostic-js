define 'kryptnostic.kryptnostic-object', [
  'require'
  'lodash'
  'kryptnostic.chunking.registry'
  'kryptnostic.object-metadata'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.kryptnostic-object'
  'kryptnostic.block-encryption-service'
  'kryptnostic.logger'
], (require) ->
  'use strict'

  _                        = require 'lodash'
  validator                = require 'kryptnostic.schema.validator'
  SCHEMA                   = require 'kryptnostic.schema.kryptnostic-object'
  ChunkingStrategyRegistry = require 'kryptnostic.chunking.registry'
  ObjectMetadata           = require 'kryptnostic.object-metadata'
  BlockEncryptionService   = require 'kryptnostic.block-encryption-service'
  Logger                   = require 'kryptnostic.logger'

  logger = Logger.get('KryptnosticObject')

  #
  # Representation of a Kryptnostic document.
  # Document is either either in a chunked/encrypted form or a joined/decrypted form.
  # Encryption and decryption do not mutate the object, but rather return new instances.
  # Encryption and decryption will no-op if object is already in the desired state.
  #
  # Author: rbuckheit
  #
  class KryptnosticObject

    # construct using a raw json object
    constructor : (raw) ->
      _.extend(this, raw)
      @validate()

    # validate json properies
    validate : ->
      validator.validate(this, KryptnosticObject, SCHEMA)

    # create using a raw json object from the api
    @createFromEncrypted : (raw) ->
      return new KryptnosticObject(raw)

    # create using a pending object id and unencrypted body
    @createFromDecrypted : ({ id, body }) ->
      metadata = new ObjectMetadata({ id })
      logger.info('metadata', metadata)
      body = {data: body}
      return new KryptnosticObject({ metadata, body })

    # true if data is in chunked/encrypted form, false otherwise.
    isEncrypted : ->
      return _.isArray(@body.data)

    # true if data is in joined/decrypted form, false otherwise.
    isDecrypted : ->
      return !@isEncrypted()

    # decrypt and join object using a cryptoService
    decrypt : (cryptoService) ->
      if @isDecrypted()
        return this
      else
        blockEncryptionService = new BlockEncryptionService()
        chunks                 = blockEncryptionService.decrypt(@body.data, cryptoService)
        chunkingStrategyUri    = @body.data.chunkingStrategy
        chunkingStrategyClass  = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy       = new chunkingStrategyClass()
        data                   = chunkingStrategy.join(chunks)
        raw                    = _.extend({}, _.cloneDeep(this), { body: { data } })
        return new KryptnosticObject(raw)

    # chunk and encrypt using a cryptoService
    encrypt : (cryptoService) ->
      if @isEncrypted()
        return this
      else
        blockEncryptionService = new BlockEncryptionService()
        chunkingStrategyUri    = @body.data.chunkingStrategy
        chunkingStrategyClass  = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy       = new chunkingStrategyClass()
        chunks                 = chunkingStrategy.split(@body.data)
        data                   = blockEncryptionService.encrypt(chunks, cryptoService)
        raw                    = _.extend({}, _.cloneDeep(this), { body: { data } })
        return new KryptnosticObject(raw)

  return KryptnosticObject
