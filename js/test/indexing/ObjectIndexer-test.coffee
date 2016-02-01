define [
  'require',
  'kryptnostic.indexing.inverted-index-segment',
  'kryptnostic.indexing.object-indexer'
], (require) ->

  # kryptnostic
  InvertedIndexSegment = require 'kryptnostic.indexing.inverted-index-segment'
  ObjectIndexer = require 'kryptnostic.indexing.object-indexer'

  MOCK_OBJECT_KEY = {
    objectId      : 'fe9bbd2a-eddc-493b-87d8-821ad376db36',
    objectVersion : 0
  }

  MOCK_PARENT_OBJECT_KEY = {
    objectId      : '8ec69cff-7b20-41e4-a2c3-835161a7555d',
    objectVersion : 0
  }

  MOCK_DATA =
    'master of puppets master of puppets master of puppets.' +
    'Master. Master. Master. Master. Master. Master. Master. Master. Master. Master.'

  MOCK_DATA_METADATA = [
    new InvertedIndexSegment({
      objectKey       : MOCK_OBJECT_KEY,
      parentObjectKey : MOCK_PARENT_OBJECT_KEY,
      token           : 'master',
      indices         : [0, 18, 36, 54, 62, 70, 78, 86, 94, 102]
    }),
    new InvertedIndexSegment({
      objectKey       : MOCK_OBJECT_KEY,
      parentObjectKey : MOCK_PARENT_OBJECT_KEY,
      token           : 'master',
      indices         : [110, 118, 126, -1, -1, -1, -1, -1, -1, -1]
    }),
    new InvertedIndexSegment({
      objectKey       : MOCK_OBJECT_KEY,
      parentObjectKey : MOCK_PARENT_OBJECT_KEY,
      token           : 'of',
      indices         : [7, 25, 43, -1, -1, -1, -1, -1, -1, -1]
    }),
    new InvertedIndexSegment({
      objectKey       : MOCK_OBJECT_KEY,
      parentObjectKey : MOCK_PARENT_OBJECT_KEY,
      token           : 'puppets',
      indices         : [10, 28, 46, -1, -1, -1, -1, -1, -1, -1]
    })
  ]

  describe 'ObjectIndexer', ->

    describe 'index()', ->

      it 'should return an empty array if the object key is invalid', ->

        invalidObjectKeys = [undefined, null, [], {}, 0, '', ' ', /regex/]
        _.forEach(invalidObjectKeys, (invalidObjectKey) ->
          objectIndexer = new ObjectIndexer()
          invertedIndexSegments = objectIndexer.buildInvertedIndexSegments(
            MOCK_DATA,
            invalidObjectKey
          )
          expect(invertedIndexSegments).toEqual([])
        )

      it 'should return an empty array if the parent object key is specified and invalid', ->

        invalidObjectKeys = [[], {}, 0, '', ' ', /regex/]
        _.forEach(invalidObjectKeys, (invalidObjectKey) ->
          objectIndexer = new ObjectIndexer()
          invertedIndexSegments = objectIndexer.buildInvertedIndexSegments(
            MOCK_DATA,
            MOCK_OBJECT_KEY,
            invalidObjectKey
          )
          expect(invertedIndexSegments).toEqual([])
        )

      it 'should return an empty array for invalid input', ->

        invalidInput = [undefined, null, [], {}, 0, '', ' ', /regex/]
        _.forEach(invalidInput, (input) ->
          objectIndexer = new ObjectIndexer()
          invertedIndexSegments = objectIndexer.buildInvertedIndexSegments(
            input,
            MOCK_OBJECT_KEY
          )
          expect(invertedIndexSegments).toEqual([])
        )

      it 'should return an array of inverted index segments', ->

        objectIndexer = new ObjectIndexer()
        invertedIndexSegments = objectIndexer.buildInvertedIndexSegments(
          MOCK_DATA,
          MOCK_OBJECT_KEY,
          MOCK_PARENT_OBJECT_KEY
        )
        expect(invertedIndexSegments).toEqual(MOCK_DATA_METADATA)
