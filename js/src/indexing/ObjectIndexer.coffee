define 'kryptnostic.indexing.object-indexer', [
  'require',
  'kryptnostic.indexing.inverted-index-segment',
  'kryptnostic.indexing.object-tokenizer',
  'kryptnostic.validators'
], (require) ->

  # kryptnostic
  InvertedIndexSegment = require 'kryptnostic.indexing.inverted-index-segment'
  ObjectTokenizer  = require 'kryptnostic.indexing.object-tokenizer'

  # utils
  Validators = require 'kryptnostic.validators'

  { validateVersionedObjectKey } = Validators

  class ObjectIndexer

    constructor: ->
      @objectTokenizer = new ObjectTokenizer()

    buildInvertedIndexSegments: (data, objectKey, parentObjectKey) ->

      # objectKey must be a valid VersionedObjectKey
      if not validateVersionedObjectKey(objectKey)
        return []

      # if parentObjectKey is specified, it must be a valid VersionedObjectKey
      if not _.isUndefined(parentObjectKey) and not _.isNull(parentObjectKey) and
          not validateVersionedObjectKey(parentObjectKey)
        return []

      paddedInvertedIndex = @objectTokenizer.buildPaddedInvertedIndex(data)

      invertedIndexSegments = []
      _.map(paddedInvertedIndex, (indexBuckets, token) ->
        _.forEach(indexBuckets, (bucket) ->
          segment = new InvertedIndexSegment({
            objectKey       : objectKey,
            parentObjectKey : parentObjectKey,
            token           : token,
            indices         : bucket
          })
          invertedIndexSegments.push(segment)
        )
      )

      return invertedIndexSegments

  return ObjectIndexer
