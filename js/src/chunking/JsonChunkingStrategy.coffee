define 'kryptnostic.chunking.strategy.json', [
  'require'
  'lodash'
], (require) ->

  _ = require 'lodash'

  validateChunks = (chunks) ->
    unless chunks.length is 1
      throw new Error 'expected exactly one chunk'

  #
  # Chunking strategy for JSON objects.
  # Returns the stringified object as a single chunk.
  #
  class JsonChunkingStrategy

    @URI : 'com.kryptnostic.kodex.v1.serialization.crypto.JsonChunkingStrategy'

    split : (object) ->
      chunk = JSON.stringify(object)
      return [ chunk ]

    join : (chunks) ->
      validateChunks(chunks)
      return JSON.parse(_.first(chunks))

  return JsonChunkingStrategy
