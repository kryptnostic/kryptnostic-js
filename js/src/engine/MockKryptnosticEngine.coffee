define 'kryptnostic.mock.kryptnostic-engine', [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  #
  # Stand-in for the FHE engine which returns mocked values.
  # This class does not provide any security guarantees.
  #
  # Author: rbuckheit
  #
  class MockKryptnosticEngine

    # client keys
    # ===========

    getFhePrivateKey: ->
      return BinaryUtils.stringToUint8('fhe.priv')

    getSearchPrivateKey: ->
      return BinaryUtils.stringToUint8('search.pvt')

    getClientHashFunction: ->
      return BinaryUtils.stringToUint8('client.hashfun')

    # indexing
    # ========

    getObjectSearchKey: (id) ->
      return BinaryUtils.stringToUint8('doc.search')

    getObjectAddressFunction: (id) ->
      return BinaryUtils.stringToUint8('doc.addressfun')

    getObjectConversionMatrix: (id) ->
      return BinaryUtils.stringToUint8('doc.conversion')

    getObjectIndexPair: (id) ->
      return BinaryUtils.stringToUint8('doc.index')

    # pair of docSearchKey, docAddressFunction
    getObjectSharingPair: (id) ->
      return BinaryUtils.stringToUint8('doc.sharing')

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return BinaryUtils.stringToUint8('search.token.' + BinaryUtils.uint8ToString(token))

    getTokenAddress: (token, objectAddressFunction, objectSearchKey) ->
      return BinaryUtils.stringToUint8('search.address.' + BinaryUtils.uint8ToString(token))

  return MockKryptnosticEngine
