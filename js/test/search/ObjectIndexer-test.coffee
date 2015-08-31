define [
  'require'
  'kryptnostic.search.indexer'
], (require) ->

  ObjectIndexer = require 'kryptnostic.search.indexer'

  describe 'ObjectIndexer', ->

    describe '#index', ->

      it 'should produce a list containing metadata per-token', ->
        objectIndexer = new ObjectIndexer()
        source = 'i fish for fish.'
        id     = 'abcd'
        expectedMetadata = [
          { id, locations: [ 0 ], token: 'i' }
          { id, locations: [ 2, 11 ], token: 'fish' }
          { id, locations: [ 7 ], token: 'for' }
        ]
        expect(objectIndexer.index(id, source)).toEqual(expectedMetadata)
