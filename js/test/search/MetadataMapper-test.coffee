define [
  'require'
  'lodash'
  'kryptnostic.mock.fhe-engine'
  'kryptnostic.search.metadata-mapper'
], (require) ->

  _                     = require 'lodash'
  MockKryptnosticEngine = require 'kryptnostic.mock.fhe-engine'
  MetadataMapper        = require 'kryptnostic.search.metadata-mapper'

  STATIC_INDEX = 10

  class StaticIndexGenerator
    generate: (count) ->
      return _.fill(Array(count), STATIC_INDEX)

  describe 'MetadataMapper', ->

    { kryptnosticEngine, metadataMapper } = {}

    beforeEach ->
      kryptnosticEngine = new MockKryptnosticEngine()
      indexGenerator    = new StaticIndexGenerator()
      metadataMapper    = new MetadataMapper()
      _.extend(metadataMapper, { kryptnosticEngine, indexGenerator })

    describe '#mapToKeys', ->

      xit 'should pad all tokens with murmurhash3-128', ->
        # FIXME

      it 'should map metadata to their indexed locations', ->
        id       = 'some-object-id'
        metadata = [
          { id, locations: [ 0, 9 ], token: 'fish' }
          { id, locations: [ 5 ], token: 'for' }
        ]
        documentKey    = kryptnosticEngine.getDocumentSearchKey(id)
        mappedMetadata = metadataMapper.mapToKeys({ metadata, documentKey })
        keys           = _.keys(mappedMetadata)
        expectedKeys   = [ 'mock-token-index-fish', 'mock-token-index-for' ]
        expect(keys).toEqual(expectedKeys)

      it 'should balance all index lists to the same length', ->
        id       = 'some-object-id'
        metadata = [
          { id, locations: [ 0 ], token: 'we' }
          { id, locations: [ 3, 12, 17 ], token: 'fish' }
          { id, locations: [ 8 ], token: 'for' }
        ]
        documentKey      = kryptnosticEngine.getDocumentSearchKey(id)
        mappedMetadata   = metadataMapper.mapToKeys({ metadata, documentKey })
        balancedMetadata = _.flatten(_.values(mappedMetadata))

        for metadata in balancedMetadata
          expect(metadata.locations.length).toBe(3)

      it 'should skip tokens of length <= 1', ->
        id       = 'some-object-id'
        metadata = [
          { id, locations: [ 0 ], token: 'i' }
          { id, locations: [ 2, 11 ], token: 'fish' }
          { id, locations: [ 7 ], token: 'for' }
        ]
        documentKey      = kryptnosticEngine.getDocumentSearchKey(id)
        mappedMetadata   = metadataMapper.mapToKeys({ metadata, documentKey })
        balancedMetadata = _.flatten(_.values(mappedMetadata))

        expect(balancedMetadata.length).toBe(2)

        expectedIndices = [ 'mock-token-index-for', 'mock-token-index-fish' ].sort()
        expect(_.keys(mappedMetadata).sort()).toEqual(expectedIndices)

        tokens = _.pluck(balancedMetadata, 'token')
        expectedTokens = [ 'fish', 'for' ]
        expect(tokens).toEqual(expectedTokens)

      it 'should produce the expected mapping for fixed inputs', ->
        id       = 'some-object-id'
        metadata = [
          { id, locations: [ 0 ], token: 'i' }
          { id, locations: [ 2, 11 ], token: 'fish' }
          { id, locations: [ 7 ], token: 'for' }
        ]
        documentKey    = kryptnosticEngine.getDocumentSearchKey(id)
        mappedMetadata = metadataMapper.mapToKeys({ metadata, documentKey })
        expect(mappedMetadata).toEqual({
          'mock-token-index-fish' : [
            { id: 'some-object-id', token: 'fish', locations: [ 2, 11 ] }
          ]
          'mock-token-index-for'  : [
            { id: 'some-object-id', token: 'for', locations: [ 7, 10 ] }
          ]
        })

      it 'should handle a simulated index hash collision', ->
        id       = 'some-object-id'
        metadata = [
          { id, locations: [ 0 ], token: 'fish' }
          { id, locations: [ 2, 11 ], token: 'fish' }
        ]
        documentKey     = kryptnosticEngine.getDocumentSearchKey(id)
        mappedMetadata = metadataMapper.mapToKeys({ metadata, documentKey })
        expect(mappedMetadata).toEqual({
          'mock-token-index-fish' : [
            { id: 'some-object-id', token: 'fish', locations: [ 0, 10 ] }
            { id: 'some-object-id', token: 'fish', locations: [ 2, 11 ] }
          ]
        })
