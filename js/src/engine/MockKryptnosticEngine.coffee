define 'kryptnostic.mock.fhe-engine', [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  # explode a string to a binary array.
  explode = (string) ->
    return BinaryUtils.stringToUint8(string)

  # collapse a binary array into a string.
  collapse = (uint8) ->
    return BinaryUtils.uint8ToString(uint8)

  #
  # Stand-in for the FHE engine which returns mocked values.
  # This class intentionally does not provide any security.
  #
  # Author: rbuckheit
  #
  class MockKryptnosticEngine

    # client keys
    # ===========

    getFhePrivateKey: ->
      return explode('fhe.pvt')

    getSearchPrivateKey: ->
      return explode('search.pvt')

    getClientHashFunction: ->
      return explode('client.hash')

    # indexing
    # ========

    getObjectSearchKey: (id) ->
      return explode('doc.search')

    getObjectAddressFunction: (id) ->
      return explode('doc.address')

    getObjectConversionMatrix: (id) ->
      return explode('doc.conversion')

    getObjectIndexPair: (id) ->
      return explode('doc.index')

    # pair of docSearchKey, docAddressFunction
    getObjectSharingPair: (id) ->
      return explode('doc.sharing')

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return explode('search.token.' + collapse(token))

    getTokenAddress: (token, documentKey) ->
      return explode('search.address.' + collapse(token))

  return MockKryptnosticEngine
