define 'kryptnostic.mock.search-key-generator', [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  pad = (string) ->
    if string.length % 2 is 0 then string else string + SPACE

  #
  # Mock implementation of SearchKeyGenerator which returns static data.
  # Keys are padded to ensure length is divisible by 2.
  #
  class MockSearchKeyGenerator

    generateClientKeys: ->
      return {
        fhePrivateKey      : BinaryUtils.stringToUint8(pad('fhe.priv'))
        searchPrivateKey   : BinaryUtils.stringToUint8(pad('search.pvt'))
        clientHashFunction : BinaryUtils.stringToUint8(pad('hash.fun'))
      }

  return MockSearchKeyGenerator
