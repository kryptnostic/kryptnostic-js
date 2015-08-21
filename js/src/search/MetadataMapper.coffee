define 'kryptnostic.search.metadata-mapper', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.binary-utils'
  'kryptnostic.hash-function'
  'kryptnostic.mock.fhe-engine'
  'kryptnostic.search.random-index-generator'
], (require) ->

  Logger               = require 'kryptnostic.logger'
  BinaryUtils          = require 'kryptnostic.binary-utils'
  HashFunction         = require 'kryptnostic.hash-function'
  MockFheEngine        = require 'kryptnostic.mock.fhe-engine'
  RandomIndexGenerator = require 'kryptnostic.search.random-index-generator'

  MINIMUM_TOKEN_LENGTH = 1

  log = Logger.get('MetadataMapper')

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
      @hashFunction   = HashFunction.MURMUR3_128

    mapToKeys: ({ metadata, documentKey }) ->
      metadataMap  = {}
      bucketLength = computeBucketSize(metadata)

      for metadatum in metadata
        { token, locations, id } = metadatum

        if token.length <= MINIMUM_TOKEN_LENGTH
          continue

        # token -> 128 bit hex -> Uint8Array
        tokenHex  = @hashFunction(token)
        tokenUint = BinaryUtils.hexToUint(tokenHex)

        # compute address of token
        indexUint   = @fheEngine.getTokenAddress(tokenUint, documentKey)
        indexString = BinaryUtils.uint8ToString(indexUint)

        # pad occurence locations
        paddedLocations = @subListAndPad(locations, bucketLength)

        balancedMetadatum = { id, token, locations : paddedLocations }

        if metadataMap[indexString]
          metadataMap[indexString].push(balancedMetadatum)
        else
          metadataMap[indexString] = [ balancedMetadatum ]

      return metadataMap

    #
    # pads list of search token locations to a balanced length.
    #
    subListAndPad : (locations, desiredLength) ->
      padCount     = desiredLength - locations.length
      falseIndices = @indexGenerator.generate(padCount)
      return locations.concat(falseIndices)

  return MetadataMapper

