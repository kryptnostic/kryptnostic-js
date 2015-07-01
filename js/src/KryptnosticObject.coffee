define 'soteria.kryptnostic-object', [
  'require'
  'lodash'
  'soteria.chunking.registry'
  'soteria.object-metadata'
], (require) ->
  'use strict'

  _                        = require 'lodash'
  ChunkingStrategyRegistry = require 'soteria.chunking.registry'
  ObjectMetadata           = require 'soteria.object-metadata'

  #
  # Representation of a Kryptnostic document.
  # Document is either either in a chunked/encryped form or a joined/decrypted form.
  # Encryption and decryption do not mutate the object, but rather return new instances.
  # Encryption and decryption will no-op if object is already in the desired state.
  #
  # Author: rbuckheit
  #
  class KryptnosticObject

    # construct using a raw json object
    constructor : (raw) ->
      _.extend(this, raw)

    # create using a raw json object from the api
    @createFromEncrypted : (raw) ->
      # TODO: schema validation
      return new KryptnosticObject(raw)

    # create using a pending object id and unencrypted body
    @createFromDecrypted : ({id, body}) ->
      metadata = new ObjectMetadata({id})
      body     = {data: body}
      return new KryptnosticObject({metadata, body})

    # true if data is in chunked/encrypted form, false otherwise.
    isEncrypted : ->
      return _.isArray(@body.data)

    # true if data is in joined/decrypted form, false otherwise.
    isDecrypted : ->
      return !@isEncrypted()

    # decrypt and join object using a cryptoService
    decrypt : (cryptoService) ->
      if @isDecrypted(this)
        return this
      else
        decryptedBlocks       = @body.data.map((chunk) -> cryptoService.decrypt(chunk.block))
        chunkingStrategyUri   = @body.data.chunkingStrategy
        chunkingStrategyClass = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy      = new chunkingStrategyClass()
        data                  = chunkingStrategy.join(decryptedBlocks)
        raw                   = _.extend({}, _.cloneDeep(this), {body: {data}})
        return new KryptnosticObject(raw)

    # chunk and encrypt using a cryptoService
    encrypt : (cryptoService) ->
      if @isEncrypted(this)
        return this
      else
        chunkingStrategyUri   = @body.data.chunkingStrategy
        chunkingStrategyClass = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy      = new chunkingStrategyClass()
        blocks                = chunkingStrategy.split(@body.data)
        data                  = blocks.map((block) -> cryptoService.encrypt(block))
        raw                   = _.extend({}, _.cloneDeep(this), {body: {data}})
        return new KryptnosticObject(raw)

  return KryptnosticObject
