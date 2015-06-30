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
  # Operations using instance methods do not mutate the object, but rather return a new instance.
  # Author: rbuckheit
  #
  class KryptnosticObject

    # construct using a raw json object from the api
    constructor : (raw) ->
      _.extend(this, raw)

    # true if data is in chunked/encrypted form, false if in joined/decrypted form
    isEncrypted : ->
      return _.isArray(this.body.data)

    # decrypt object using a cryptoService
    decrypt : (cryptoService) ->
      if @isEncrypted(this)
        chunkingStrategyUri   = @body.data.chunkingStrategy
        chunkingStrategyClass = ChunkingStrategyRegistry.get(chunkingStrategyUri)
        chunkingStrategy      = new chunkingStrategyClass()
        decryptedBlocks       = @body.data.map((chunk) -> cryptoService.decrypt(chunk.block))
        data                  = chunkingStrategy.join(decryptedBlocks)
        raw                   = _.extend({}, _.cloneDeep(this), {body: {data}})
        return new KryptnosticObject(raw)
      else
        return this

  return KryptnosticObject
