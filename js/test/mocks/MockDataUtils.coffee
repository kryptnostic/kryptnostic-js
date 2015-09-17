define 'kryptnostic.mock.mock-data-utils', [
  'require'
], (require) ->

  class MockDataUtils

    @INDEX_TOKEN_SIZE          = 16
    @FHE_PRIVATE_KEY_SIZE      = 329760
    @SEARCH_PRIVATE_KEY_SIZE   = 4096
    @CLIENT_HASH_FUNCTION_SIZE = 1060896
    @OBJECT_INDEX_PAIR_SIZE    = 2064
    @OBJECT_SHARE_PAIR_SIZE    = 2064
    @OBJECT_SEARCH_PAIR_SIZE   = 2080

    #
    # generates a random 8-bit unsigned integer [0, 255]
    #
    @generateRandom8bitInteger: ->
      min = 0
      max = 255
      return Math.floor(Math.random() * (max - min + 1) + min)

    #
    # generates a Uint8Array filled with random 8-bit unsigned integers
    #
    @generateRandomUint8Array: (size) ->
      i = 0
      uint8 = new Uint8Array(size)
      while i < size
        uint8[i] = @generateRandom8bitInteger()
        i++
      return uint8

    #
    # generates a mock FHE private key represented as a Uint8Array
    #
    @generateMockFhePrivateKeyAsUint8: ->
      return @generateRandomUint8Array(@FHE_PRIVATE_KEY_SIZE)

    #
    # generates a mock search private key represented as a Uint8Array
    #
    @generateMockSearchPrivateKeyAsUint8: ->
      return @generateRandomUint8Array(@SEARCH_PRIVATE_KEY_SIZE)

    #
    # generates a mock search token represented as a Uint8Array
    #
    @generateMockIndexTokenAsUint8: ->
      return @generateRandomUint8Array(@INDEX_TOKEN_SIZE)
