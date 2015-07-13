# mock data
# =========

DATA_LONG = [0...8000].map((i) -> 'a').join('')

DATA_LONG_SPLIT = [
  [0...4096].map((i) -> 'a').join(''),
  [4096...8000].map((i) -> 'a').join('')
]

# tests
# =====

define ['require', 'soteria.chunking.strategy.default'], (require) ->

  DefaultChunkingStrategy = require('soteria.chunking.strategy.default')

  describe 'DefaultChunkingStrategy', ->

    describe 'URI', ->

      it 'should not change because it is long term serialized', ->
        expectedUri = 'soteria.chunking.strategy.default'
        expect(DefaultChunkingStrategy.URI).toEqual(expectedUri)

    describe '#split', ->

      it 'should split data over 4096 byte intervals', ->
        chunkingStrategy = new DefaultChunkingStrategy()
        expect(chunkingStrategy.split(DATA_LONG)).toEqual(DATA_LONG_SPLIT)

    describe '#join', ->

      it 'should join chunks', ->
        chunkingStrategy = new DefaultChunkingStrategy()
        expect(chunkingStrategy.join(DATA_LONG_SPLIT)).toEqual(DATA_LONG)
