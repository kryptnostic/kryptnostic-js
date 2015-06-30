define 'soteria.kryptnostic-object', [
  'require'
  'lodash'
  'soteria.chunking.registry'
], (require) ->
  'use strict'

  _                        = require 'lodash'
  ChunkingStrategyRegistry = require 'soteria.chunking.registry'

  #
  # Chunked and encrypted representation of a document.
  # Decryption does not mutate the object, but rather returns a new instance.
  #
  # Author: rbuckheit
  #
  class KryptnosticObject

    # construct using a raw json object from the api
    constructor : (raw) ->
      _.extend(this, raw)

    # true if data is in chunked/encrypted form, false if in joined/decrypted form
    isEncrypted : ->
      return _.isArray(@body.data)

    # decrypt object using a cryptoService
    decrypt : (cryptoService) ->
      if @isEncrypted(this)
        decryptedBlocks       = @body.data.map((chunk) -> cryptoService.decrypt(chunk.block))
        chunkingStrategyClass = ChunkingStrategyRegistry.get(@body.data.chunkingStrategy)
        chunkingStrategy      = new chunkingStrategyClass()
        data                  = chunkingStrategy.join(decryptedBlocks)
        raw                   = _.extend({}, _.cloneDeep(this), {body: {data}})
        return new KryptnosticObject(raw)
      else
        return this

  return KryptnosticObject
