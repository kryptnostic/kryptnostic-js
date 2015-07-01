define 'soteria.kryptnostic-object', [
  'require'
  'lodash'
  'soteria.chunking.registry'
  'soteria.object-metadata'
  'soteria.schema.validator'
  'soteria.schema.kryptnostic-object'
  'soteria.block-encryption-service'
], (require) ->
  'use strict'

  _                        = require 'lodash'
  validator                = require 'soteria.schema.validator'
  SCHEMA                   = require 'soteria.schema.kryptnostic-object'
  ChunkingStrategyRegistry = require 'soteria.chunking.registry'
  ObjectMetadata           = require 'soteria.object-metadata'
  BlockEncryptionService   = require 'soteria.block-encryption-service'

  log = (message, args...) ->
    console.info("[KryptnosticObject] #{message} #{args.map(JSON.stringify)}")

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
      @blockEncryptionService = new BlockEncryptionService()
      @validate()

    # validate json properies
    validate : ->
      validator.validate(this, KryptnosticObject, SCHEMA)

    # create using a raw json object from the api
    @createFromEncrypted : (raw) ->
      return new KryptnosticObject(raw)

    # create using a pending object id and unencrypted body
    @createFromDecrypted : ({id, body}) ->
      metadata = new ObjectMetadata({id})
      log('metadata', metadata)
      body = {data: body}
      return new KryptnosticObject({metadata, body})

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
        # TODO: use the block encryption service!
        decryptedBlocks       = @body.data.map((chunk) -> cryptoService.decrypt(chunk.block))
        chunkingStrategyUri   = @body.data.chunkingStrategy
        chunkingStrategyClass = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy      = new chunkingStrategyClass()
        data                  = chunkingStrategy.join(decryptedBlocks)
        raw                   = _.extend({}, _.cloneDeep(this), {body: {data}})
        return new KryptnosticObject(raw)

    # chunk and encrypt using a cryptoService
    encrypt : (cryptoService) ->
      if @isEncrypted()
        return this
      else
        chunkingStrategyUri   = @body.data.chunkingStrategy
        chunkingStrategyClass = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy      = new chunkingStrategyClass()
        chunks                = chunkingStrategy.split(@body.data)
        data                  = @blockEncryptionService.encrypt(chunks, cryptoService)
        raw                   = _.extend({}, _.cloneDeep(this), {body: {data}})
        return new KryptnosticObject(raw)

  return KryptnosticObject
