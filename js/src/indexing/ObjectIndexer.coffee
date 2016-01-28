define 'kryptnostic.indexing.object-indexer', [
  'require',
  'kryptnostic.indexing.bucketed-metadata',
  'kryptnostic.indexing.object-tokenizer',
  'kryptnostic.validators'
], (require) ->

  # kryptnostic
  BucketedMetadata = require 'kryptnostic.indexing.bucketed-metadata'
  ObjectTokenizer  = require 'kryptnostic.indexing.object-tokenizer'

  # utils
  Validators = require 'kryptnostic.validators'

  { validateVersionedObjectKey } = Validators

  class ObjectIndexer

    constructor: ->
      @objectTokenizer = new ObjectTokenizer()

    index: (objectKey, data) ->

      if not validateVersionedObjectKey(objectKey)
        return []

      invertedIndex = @objectTokenizer.analyze(data)

      metadata = _.map(invertedIndex, (indices, token) ->
        bucketedMetadata = new BucketedMetadata({
          key    : objectKey,
          token  : token,
          index  : indices,
          length : indices.length
        })
        return bucketedMetadata
      )

      return metadata

  return ObjectIndexer
