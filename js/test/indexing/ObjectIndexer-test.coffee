define [
  'require',
  'kryptnostic.indexing.bucketed-metadata',
  'kryptnostic.indexing.object-indexer'
], (require) ->

  # kryptnostic
  BucketedMetadata = require 'kryptnostic.indexing.bucketed-metadata'
  ObjectIndexer = require 'kryptnostic.indexing.object-indexer'

  MOCK_OBJECT_KEY  = {
    objectId      : 'fe9bbd2a-eddc-493b-87d8-821ad376db36',
    objectVersion : 0
  }

  MOCK_DATA =
    'master of puppets master of puppets master of puppets.' +
    'Master. Master. Master. Master. Master. Master. Master. Master. Master. Master.'

  MOCK_DATA_METADATA = [
    new BucketedMetadata({
      key    : MOCK_OBJECT_KEY,
      token  : 'master',
      index  : [[0, 18, 36, 54, 62, 70, 78, 86, 94, 102], [110, 118, 126]],
      length : 2
    }),
    new BucketedMetadata({
      key    : MOCK_OBJECT_KEY,
      token  : 'of',
      index  : [[7, 25, 43]],
      length : 1
    }),
    new BucketedMetadata({
      key    : MOCK_OBJECT_KEY,
      token  : 'puppets',
      index  : [[10, 28, 46]],
      length : 1
    })
  ]

  describe 'ObjectIndexer', ->

    describe 'index()', ->

      it 'should return an empty array if the object key is invalid', ->

        invalidObjectKeys = [undefined, null, [], {}, 0, '', ' ', /regex/]
        _.forEach(invalidObjectKeys, (objectKey) ->
          objectIndexer = new ObjectIndexer()
          metadata = objectIndexer.index(objectKey, MOCK_DATA)
          expect(metadata).toEqual([])
        )

      it 'should return an empty array for invalid input', ->

        invalidInput = [undefined, null, [], {}, 0, '', ' ', /regex/]
        _.forEach(invalidInput, (input) ->
          objectIndexer = new ObjectIndexer()
          metadata = objectIndexer.index(MOCK_OBJECT_KEY, input)
          expect(metadata).toEqual([])
        )

      it 'should return an array of metadata per token', ->

        objectIndexer = new ObjectIndexer()
        metadata = objectIndexer.index(MOCK_OBJECT_KEY, MOCK_DATA)
        expect(metadata).toEqual(MOCK_DATA_METADATA)
