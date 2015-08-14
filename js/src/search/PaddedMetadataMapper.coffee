define 'kryptnostic.search.metadata-mapper', [
  'require'
  'kryptnostic.search.random-index-generator'
], (require) ->

  RandomIndexGenerator = require 'kryptnostic.search.random-index-generator'

  MINIMUM_TOKEN_LENGTH    = 1

  #
  # compute size of largest metadata bucket for padding.
  #
  computeBucketSize = (metadata) ->
    return _.reduce(metadata, (max, metadatum) ->
      return Math.max(max, metadatum.locations.length)
    , 0)

  #
  # Maps search token metadata { token, id, locations } to their
  # indexed locations, padding the locations of the token so that all
  # lists of metadata locations are balanced.
  #
  # Author: rbuckheit
  #
  class PaddedMetadataMapper

    constructor : ({ @fheEngine, @indexGenerator }) ->
      @indexGenerator ?= new RandomIndexGenerator()

    mapTokensToKeys : ({ metadata, sharingKey }) ->
      metadataMap  = {}
      bucketLength = computeBucketSize(metadata)

      for metadatum in metadata
        { token, locations, id } = metadatum

        if token.length <= MINIMUM_TOKEN_LENGTH
          continue

        indexForTerm    = @fheEngine.mapTokenToIndex({ token, sharingKey })
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

  return PaddedMetadataMapper

