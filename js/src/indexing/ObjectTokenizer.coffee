define 'kryptnostic.indexing.object-tokenizer', [
  'require'
], (require) ->

  class ObjectTokenizer

    @DEFAULT_BUCKET_SIZE = 10

    TOKEN_REGEX = /([a-zA-Z0-9']+)/g

    constructor: (bucketSize) ->

      if _.isInteger(bucketSize) and bucketSize > 0
        @bucketSize = bucketSize
      else
        @bucketSize = ObjectTokenizer.DEFAULT_BUCKET_SIZE

    analyze: (data) ->

      if not _.isString(data)
        return {}

      invertedIndex = {}

      while (match = TOKEN_REGEX.exec(data))

        word  = match[0].toLowerCase() # [0] is the full string of characters matched
        index = match.index # the 0-based index of the match in the string
        indices = invertedIndex[word]

        if not indices
          indices = [[]]
          invertedIndex[word] = indices
        else if indices[indices.length - 1].length == @bucketSize
          indices.push([])

        indices[indices.length - 1].push(index)

      return invertedIndex

  return ObjectTokenizer
