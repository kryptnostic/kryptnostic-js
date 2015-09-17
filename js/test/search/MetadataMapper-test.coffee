define [
  'require'
  'lodash'
  'kryptnostic.logger'
  'kryptnostic.binary-utils'
  'kryptnostic.mock.kryptnostic-engine'
  'kryptnostic.search.metadata-mapper'
], (require) ->

  _                     = require 'lodash'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  MockKryptnosticEngine = require 'kryptnostic.mock.kryptnostic-engine'
  MetadataMapper        = require 'kryptnostic.search.metadata-mapper'

  STATIC_INDEX = 10

  PADDED_128_BIT_HEX_STRING_LENGTH  = 128 / 4
  PADDED_128_BIT_UINT8_ARRAY_LENGTH = 128 / 8

  MOCK_HASH_FUNCTION = (i) ->
    return BinaryUtils.stringToHex(i)

  overwriteHashFunction = (metadataMapper) ->
    metadataMapper.hashFunction = MOCK_HASH_FUNCTION

  class StaticIndexGenerator
    generate: (count) ->
      return _.fill(Array(count), STATIC_INDEX)

  log = require('kryptnostic.logger').get('MetadataMapper-test')

  describe 'MetadataMapper', ->

    { engine, metadataMapper, id, documentKey } = {}

    beforeEach ->
      engine         = new MockKryptnosticEngine()
      indexGenerator = new StaticIndexGenerator()
      metadataMapper = new MetadataMapper()
      _.extend(metadataMapper, { engine, indexGenerator })
      id          = 'some-object-id'
      documentKey = 'testDocumentKey'

    describe '#mapToKeys', ->

      it 'should pad all tokens to 128 bits with murmurhash3-128 before addressing', ->
        called   = false
        metadata = [ { id, locations: [0, 9], token: 'fish' }]
        sinon.stub(metadataMapper.engine, 'calculateMetadataAddress', (objectIndexPair, token) ->
          expect(token.length).toBe(PADDED_128_BIT_UINT8_ARRAY_LENGTH)
          expect(token instanceof Uint8Array).toBe(true)
          called = true
          return new Uint8Array()
        )
        metadataMapper.mapToKeys { metadata, documentKey }
        expect(called).toBe(true)
        metadataMapper.engine.calculateMetadataAddress.restore()

      it 'should map metadata to their indexed locations', ->
        overwriteHashFunction(metadataMapper)
        metadata = [
          { id, locations: [ 0, 9 ], token: 'fish' }
          { id, locations: [ 5 ], token: 'for' }
        ]
        mappedMetadata = metadataMapper.mapToKeys({ metadata, documentKey })
        keys           = _.keys(mappedMetadata)
        expectedKeys   = [ 'search.address.fish', 'search.address.for' ]
        expect(keys).toEqual(expectedKeys)

      it 'should balance all index lists to the same length', ->
        overwriteHashFunction(metadataMapper)
        metadata = [
          { id, locations: [ 0 ], token: 'we' }
          { id, locations: [ 3, 12, 17 ], token: 'fish' }
          { id, locations: [ 8 ], token: 'for' }
        ]
        mappedMetadata   = metadataMapper.mapToKeys({ metadata, documentKey })
        balancedMetadata = _.flatten(_.values(mappedMetadata))

        for metadata in balancedMetadata
          expect(metadata.locations.length).toBe(3)

      it 'should skip tokens of length <= 1', ->
        overwriteHashFunction(metadataMapper)
        metadata = [
          { id, locations: [ 0 ], token: 'i' }
          { id, locations: [ 2, 11 ], token: 'fish' }
          { id, locations: [ 7 ], token: 'for' }
        ]
        mappedMetadata   = metadataMapper.mapToKeys({ metadata, documentKey })
        balancedMetadata = _.flatten(_.values(mappedMetadata))

        expect(balancedMetadata.length).toBe(2)

        expectedIndices = [ 'search.address.fish', 'search.address.for'  ].sort()
        expect(_.keys(mappedMetadata).sort()).toEqual(expectedIndices)

        tokens = _.pluck(balancedMetadata, 'token')
        expectedTokens = [ 'fish', 'for' ]
        expect(tokens).toEqual(expectedTokens)

      it 'should produce the expected mapping for fixed inputs', ->
        overwriteHashFunction(metadataMapper)
        metadata = [
          { id, locations: [ 0 ], token: 'i' }
          { id, locations: [ 2, 11 ], token: 'fish' }
          { id, locations: [ 7 ], token: 'for' }
        ]
        mappedMetadata = metadataMapper.mapToKeys({ metadata, documentKey })
        expect(mappedMetadata).toEqual({
          'search.address.fish' : [
            { id: 'some-object-id', token: 'fish', locations: [ 2, 11 ] }
          ]
          'search.address.for'  : [
            { id: 'some-object-id', token: 'for', locations: [ 7, 10 ] }
          ]
        })

      it 'should handle a simulated index hash collision', ->
        overwriteHashFunction(metadataMapper)
        metadata = [
          { id, locations: [ 0 ], token: 'fish' }
          { id, locations: [ 2, 11 ], token: 'fish' }
        ]
        mappedMetadata = metadataMapper.mapToKeys({ metadata, documentKey })
        expect(mappedMetadata).toEqual({
          'search.address.fish' : [
            { id: 'some-object-id', token: 'fish', locations: [ 0, 10 ] }
            { id: 'some-object-id', token: 'fish', locations: [ 2, 11 ] }
          ]
        })
