define 'kryptnostic.mock.kryptnostic-engine', [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  SPACE = ' '

  pad = (string) ->
    if string.length % 2 is 0
      return string
    else
      return string + SPACE

  #
  # Stand-in for the FHE engine which returns mocked values.
  # This class does not provide any security guarantees.
  # Some of the static data is padded with whitespace to ensure divisibility by 2.
  #
  # Author: rbuckheit
  #
  class MockKryptnosticEngine

    # client keys
    # ===========

    getFhePrivateKey: ->
      return BinaryUtils.stringToUint8(pad('fhe.priv'))

    getSearchPrivateKey: ->
      return BinaryUtils.stringToUint8(pad('search.pvt'))

    getClientHashFunction: ->
      return BinaryUtils.stringToUint8(pad('client.hashfn'))

    # indexing
    # ========

    getObjectSearchKey: (id) ->
      return BinaryUtils.stringToUint8(pad('doc.search'))

    getObjectAddressFunction: (id) ->
      return BinaryUtils.stringToUint8(pad('doc.addressfn'))

    getObjectConversionMatrix: (id) ->
      return BinaryUtils.stringToUint8(pad('doc.conversion'))

    getObjectIndexPair: (id) ->
      return BinaryUtils.stringToUint8(pad('doc.index'))

    # pair of docSearchKey, docAddressFunction
    getObjectSharingPair: (id) ->
      return BinaryUtils.stringToUint8(pad('doc.sharing'))

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return BinaryUtils.stringToUint8('search.token.' + BinaryUtils.uint8ToString(token))

    getTokenAddress: (token, objectAddressFunction, objectSearchKey) ->
      return BinaryUtils.stringToUint8('search.address.' + BinaryUtils.uint8ToString(token))

  return MockKryptnosticEngine
