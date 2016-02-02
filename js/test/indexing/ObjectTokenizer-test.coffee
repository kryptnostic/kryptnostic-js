define [
  'require',
  'kryptnostic.indexing.object-tokenizer'
], (require) ->

  ObjectTokenizer = require 'kryptnostic.indexing.object-tokenizer'

  MOCK_DATA =
    'Come crawling faster. Obey your master. Your life burns faster. Obey your master. Master.' +
    'Master of puppets Im pulling your strings. Twisting your mind and smashing your dreams.' +
    'Blinded by me, you cant see a thing. Just call my name, cause Ill hear you scream.' +
    'Master. Master. Just call my name, cause Ill hear you scream. Master. Master.'

  MOCK_DATA_INVERTED_INDEX = {
    'a'        : [[204, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'and'      : [[151, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'blinded'  : [[176, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'burns'    : [[50, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'by'       : [[184, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'call'     : [[218, 279, -1, -1, -1, -1, -1, -1, -1, -1]],
    'cant'     : [[195, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'cause'    : [[232, 293, -1, -1, -1, -1, -1, -1, -1, -1]],
    'come'     : [[0, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'crawling' : [[5, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'dreams'   : [[169, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'faster'   : [[14, 56, -1, -1, -1, -1, -1, -1, -1, -1]],
    'hear'     : [[242, 303, -1, -1, -1, -1, -1, -1, -1, -1]],
    'ill'      : [[238, 299, -1, -1, -1, -1, -1, -1, -1, -1]],
    'im'       : [[107, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'just'     : [[213, 274, -1, -1, -1, -1, -1, -1, -1, -1]],
    'life'     : [[45, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'master'   : [[32, 74, 82, 89, 258, 266, 320, 328, -1, -1]],
    'me'       : [[187, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'mind'     : [[146, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'my'       : [[223, 284, -1, -1, -1, -1, -1, -1, -1, -1]],
    'name'     : [[226, 287, -1, -1, -1, -1, -1, -1, -1, -1]],
    'obey'     : [[22, 64, -1, -1, -1, -1, -1, -1, -1, -1]],
    'of'       : [[96, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'pulling'  : [[110, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'puppets'  : [[99, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'scream'   : [[251, 312, -1, -1, -1, -1, -1, -1, -1, -1]],
    'see'      : [[200, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'smashing' : [[155, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'strings'  : [[123, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'thing'    : [[206, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'twisting' : [[132, -1, -1, -1, -1, -1, -1, -1, -1, -1]],
    'you'      : [[191, 247, 308, -1, -1, -1, -1, -1, -1, -1]],
    'your'     : [[27, 40, 69, 118, 141, 164, -1, -1, -1, -1]]
  }

  describe 'ObjectTokenizer', ->

    describe 'constructor', ->

      it 'should default to the correct bucket size', ->

        invalidBucketSizes = [undefined, null, [], {}, 0, -1, '', ' ', /regex/]
        _.forEach(invalidBucketSizes, (invalidBucketSize) ->
          objectTokenizer = new ObjectTokenizer(invalidBucketSize)
          expect(objectTokenizer.bucketSize).toEqual(ObjectTokenizer.DEFAULT_BUCKET_SIZE)
        )

    describe 'analyze()', ->

      it 'should return an empty inverted index for invalid input', ->

        invalidInput = [undefined, null, [], {}, 0, '', ' ', /regex/]
        _.forEach(invalidInput, (input) ->
          objectTokenizer = new ObjectTokenizer()
          invertedIndex = objectTokenizer.buildPaddedInvertedIndex(input)
          expect(invertedIndex).toEqual({})
        )

      it 'should return a correct inverted index with default bucket size', ->

        objectTokenizer = new ObjectTokenizer()
        invertedIndex = objectTokenizer.buildPaddedInvertedIndex(MOCK_DATA)
        expect(invertedIndex).toEqual(MOCK_DATA_INVERTED_INDEX)

      it 'should return a correct inverted index with the given bucket size', ->

        # bucket size 1
        objectTokenizer = new ObjectTokenizer(1)
        expect(objectTokenizer.bucketSize).toEqual(1)

        invertedIndex = objectTokenizer.buildPaddedInvertedIndex(MOCK_DATA)
        expect(invertedIndex.master).toEqual([[32], [74], [82], [89], [258], [266], [320], [328]])

        # bucket size 3
        objectTokenizer = new ObjectTokenizer(3)
        expect(objectTokenizer.bucketSize).toEqual(3)

        invertedIndex = objectTokenizer.buildPaddedInvertedIndex(MOCK_DATA)
        expect(invertedIndex.master).toEqual([[32, 74, 82], [89, 258, 266], [320, 328, -1]])

      it 'should return a correct inverted index without punctuation or special characters (except apostrophes)', ->

        input = 'hello .* ([_]) #world! < > @!&$% -=_+/\\| }{ ~`<^>?'
        expectedInvertedIndex = {
          hello : [[0]],
          world : [[16]]
        }
        objectTokenizer = new ObjectTokenizer(1)
        invertedIndex = objectTokenizer.buildPaddedInvertedIndex(input)
        expect(invertedIndex).toEqual(expectedInvertedIndex)

        input = "can't don't it'll we'd I've I'm it's"
        expectedInvertedIndex = {
          'can\'t' : [[0]],
          'don\'t' : [[6]],
          'it\'ll' : [[12]],
          'we\'d'  : [[18]],
          'i\'ve'  : [[23]],
          'i\'m'   : [[28]],
          'it\'s'  : [[32]]
        }
        objectTokenizer = new ObjectTokenizer(1)
        invertedIndex = objectTokenizer.buildPaddedInvertedIndex(input)
        expect(invertedIndex).toEqual(expectedInvertedIndex)
