define 'kryptnostic.search.indexer', [
  'require'
  'lodash'
  'kryptnostic.search.tokenizer'
], (require) ->

  _               = require 'lodash'
  ObjectTokenizer = require 'kryptnostic.search.tokenizer'

  #
  # Indexes an object's text for search, producing an index metadata
  # object for each token extacted from the text.
  #
  # Author: rbuckheit
  #

  class ObjectIndexer

    @index: (id, text) ->
      invertedIndex = ObjectTokenizer.analyze(text)
      metadata = _.map(invertedIndex, (locations, token) ->
        return { id, locations, token }
      )
      return metadata

  return ObjectIndexer
