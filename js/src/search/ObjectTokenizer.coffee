define 'kryptnostic.search.tokenizer', [
  'require'
  'lodash'
], (require) ->

  _ = require 'lodash'

  #
  # Tokenizes an object's text into words by splitting on whitespace.
  # Produces an inverted index mapping tokens to indices they occurred at.
  #
  # Author: rbuckheit
  #
  class ObjectTokenizer

    TOKEN_REGEX = /([a-zA-Z0-9]+)/g

    @analyze: (source) ->
      unless _.isString(source)
        throw new Error 'source must be a string'

      invertedIndex = {}

      while (match = TOKEN_REGEX.exec(source))
        index = match.index
        word  = match[0]
        if not invertedIndex[word]
          invertedIndex[word] = [index]
        else
          invertedIndex[word].push(index)

      return invertedIndex

  return ObjectTokenizer
