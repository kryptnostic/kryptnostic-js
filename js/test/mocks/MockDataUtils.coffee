define 'kryptnostic.mock.mock-data-utils', [
  'require'
  'forge'
  'kryptnostic.block-ciphertext'
], (require) ->

  # libraries
  Forge = require 'forge'

  # kryptnostic
  BlockCiphertext = require 'kryptnostic.block-ciphertext'

  class MockDataUtils

    @AES_KEY_SIZE_IN_BYTES     = 16
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
    # generates a mock client hash function represented as a Uint8Array
    #
    @generateMockClientHashFunctionAsUint8: ->
      return @generateRandomUint8Array(@CLIENT_HASH_FUNCTION_SIZE)

    #
    # generates a mock search token represented as a Uint8Array
    #
    @generateMockIndexTokenAsUint8: ->
      return @generateRandomUint8Array(@INDEX_TOKEN_SIZE)

    #
    # generates a mock BlockCipherText object out of the given data
    #
    # @param Uint8Array data - the data to encrypt
    # @param String key - a binary-encoded string of bytes
    #
    @generateMockBlockCipherText: (data, key) ->
      iv = Forge.random.getBytesSync(@AES_KEY_SIZE_IN_BYTES)
      buffer = Forge.util.createBuffer(data)
      cipher = Forge.cipher.createCipher('AES-CTR', key)
      cipher.start({ iv })
      cipher.update(buffer)
      cipher.finish()
      ciphertext = cipher.output.data
      return new BlockCiphertext({
        iv       : btoa(iv),
        salt     : btoa(Forge.random.getBytesSync(0)),
        contents : btoa(ciphertext)
      })
