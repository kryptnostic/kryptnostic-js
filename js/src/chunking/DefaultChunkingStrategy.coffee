define 'kryptnostic.chunking.strategy.default', [
  'require',
  'lodash',
], (require) ->

  _ = require 'lodash'

  BLOCK_LENGTH_IN_BYTES = 1000000

  EMPTY_STRING = ''

  #
  # Chunking strategy which separates stored data into a fixed-size chunks.
  # Author: rbuckheit
  #
  class DefaultChunkingStrategy

    @URI : 'com.kryptnostic.kodex.v1.serialization.crypto.DefaultChunkingStrategy'

    split : (data, blockBytes = BLOCK_LENGTH_IN_BYTES) ->
      return _.chain(data)
        .chunk(blockBytes)
        .map((chunkArr) -> chunkArr.join(EMPTY_STRING))
        .value()

    join : (chunks) ->
      return chunks.join(EMPTY_STRING)

  return DefaultChunkingStrategy
