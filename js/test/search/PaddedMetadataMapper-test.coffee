define [
  'require'
  'lodash'
  'kryptnostic.mock.fhe-engine'
  'kryptnostic.search.metadata-mapper'
], (require) ->

  _                    = require 'lodash'
  MockFheEngine        = require 'kryptnostic.mock.fhe-engine'
  PaddedMetadataMapper = require 'kryptnostic.search.metadata-mapper'

  STATIC_INDEX = 10

  class StaticIndexGenerator
    generate: (count) ->
      return _.fill(Array(count), STATIC_INDEX)

  describe 'PaddedMetadataMapper', ->

    { fheEngine, metadataMapper } = {}

    beforeEach ->
      fheEngine      = new MockFheEngine()
      indexGenerator = new StaticIndexGenerator()
      metadataMapper = new PaddedMetadataMapper({ fheEngine, indexGenerator })

    describe '#mapTokensToKeys', ->

      it 'should map metadata to their indexed locations', ->
        id       = 'some-object-id'
        metadata = [
          { id, locations: [ 0, 9 ], token: 'fish' }
          { id, locations: [ 5 ], token: 'for' }
        ]
        sharingKey     = fheEngine.generateSharingKey({ id })
        mappedMetadata = metadataMapper.mapTokensToKeys({ metadata, sharingKey })
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
        sharingKey     = fheEngine.generateSharingKey({ id })
        mappedMetadata = metadataMapper.mapTokensToKeys({ metadata, sharingKey })
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
        sharingKey     = fheEngine.generateSharingKey({ id })
        mappedMetadata = metadataMapper.mapTokensToKeys({ metadata, sharingKey })
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
        sharingKey     = fheEngine.generateSharingKey({ id })
        mappedMetadata = metadataMapper.mapTokensToKeys({ metadata, sharingKey })
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
        sharingKey     = fheEngine.generateSharingKey({ id })
        mappedMetadata = metadataMapper.mapTokensToKeys({ metadata, sharingKey })
        expect(mappedMetadata).toEqual({
          'mock-token-index-fish' : [
            { id: 'some-object-id', token: 'fish', locations: [ 0, 10 ] }
            { id: 'some-object-id', token: 'fish', locations: [ 2, 11 ] }
          ]
        })
