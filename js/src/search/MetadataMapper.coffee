define 'kryptnostic.search.metadata-mapper', [
  'require'
  'kryptnostic.hash-function'
  'kryptnostic.mock.fhe-engine'
  'kryptnostic.search.random-index-generator'
], (require) ->

  HashFunction         = require 'kryptnostic.hash-function'
  MockFheEngine        = require 'kryptnostic.mock.fhe-engine'
  RandomIndexGenerator = require 'kryptnostic.search.random-index-generator'

  MINIMUM_TOKEN_LENGTH = 1

  #
  # compute size of largest metadata bucket for padding.
  #
  computeBucketSize = (metadata) ->
    return _.reduce(metadata, (max, { locations }) ->
      return Math.max(max, locations.length)
    , 0)

  #
  # Maps search token metadata { token, id, locations } to their indexed locations.
  # Pads locations of the token so that all lists of locations are of equal length.
  # Hashes and pads tokens using MurmurHash3-128 so that all tokens are 128 bits.
  #
  # Author: rbuckheit
  #
  class MetadataMapper

    constructor: ->
      @fheEngine      = new MockFheEngine()
      @indexGenerator = new RandomIndexGenerator()

    mapToKeys: ({ metadata, documentKey }) ->
      metadataMap  = {}
      bucketLength = computeBucketSize(metadata)

      for metadatum in metadata
        { token, locations, id } = metadatum

        if token.length <= MINIMUM_TOKEN_LENGTH
          continue

        token = HashFunction.MURMUR3_128(token)

        indexForTerm    = @fheEngine.getTokenAddress(token, documentKey)
        paddedLocations = @subListAndPad(locations, bucketLength)

        balancedMetadatum = { id, token, locations : paddedLocations }

        if metadataMap[indexForTerm]
          metadataMap[indexForTerm].push(balancedMetadatum)
        else
          metadataMap[indexForTerm] = [ balancedMetadatum ]

      return metadataMap

    #
    # pads list of search token locations to a balanced length.
    #
    subListAndPad : (locations, desiredLength) ->
      padCount     = desiredLength - locations.length
      falseIndices = @indexGenerator.generate(padCount)

      return locations.concat(falseIndices)

  return MetadataMapper

