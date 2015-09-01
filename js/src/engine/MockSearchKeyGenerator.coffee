define 'kryptnostic.mock.search-key-generator', [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  class MockSearchKeyGenerator

    # client keys
    # ===========
    getAllClientKeys: ->
      return {
        fhePrivateKey: BinaryUtils.stringToUint8(pad('fhe.priv'))
        searchPrivateKey: BinaryUtils.stringToUint8(pad('search.pvt'))
        clientHashFunction: BinaryUtils.stringToUint8(pad('hash.fun'))
      }

  return SearchKeyGenerator
