define 'kryptnostic.indexing.object-tokenizer', [
  'require'
], (require) ->

  #
  # ToDo - PLATFORM-65 - come up with a set of rules to guide how we tokenize objects. for example, we probably
  #   shouldn't be indexing single-character words like "a" or common small words like "the". additionally, we
  #   should think about how to index more complex words that might have apostrophes, dashes, underscores, etc...
  #

  class ObjectTokenizer

    @DEFAULT_BUCKET_SIZE = 10

    TOKEN_REGEX = /([a-zA-Z0-9']+)/g

    constructor: (bucketSize) ->

      if _.isFinite(bucketSize) and bucketSize > 0
        @bucketSize = bucketSize
      else
        @bucketSize = ObjectTokenizer.DEFAULT_BUCKET_SIZE

    buildPaddedInvertedIndex: (data) ->

      if not _.isString(data)
        return {}

      invertedIndex = {}

      # build inverted index
      while (match = TOKEN_REGEX.exec(data))

        token = match[0].toLowerCase() # [0] is the full string of characters matched
        index = match.index # the 0-based index of the match in the string
        indexBuckets = invertedIndex[token]

        if not indexBuckets
          indexBuckets = [[]]
          invertedIndex[token] = indexBuckets
        else if indexBuckets[indexBuckets.length - 1].length == @bucketSize
          indexBuckets.push([])

        indexBuckets[indexBuckets.length - 1].push(index)

      # add padding to the unfilled index buckets
      _.forEach(invertedIndex, (indexBuckets) =>
        # we're guaranteed that only the last bucket might need padding
        lastBucket = indexBuckets[indexBuckets.length - 1]
        while lastBucket.length < @bucketSize
          # ToDo - generate random negative integer to pad with
          lastBucket.push(-1)
        return
      )

      return invertedIndex


  return ObjectTokenizer
