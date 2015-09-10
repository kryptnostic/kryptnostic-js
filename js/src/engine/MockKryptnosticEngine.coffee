define 'kryptnostic.mock.kryptnostic-engine', [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  SPACE = ' '

  pad = (string) ->
    if string.length % 2 is 0 then string else string + SPACE

  #
  # Stand-in for the FHE engine which returns mocked values.
  # This class does not provide any security guarantees.
  # Some of the static data is padded with whitespace to ensure divisibility by 2.
  #
  # Author: rbuckheit
  #
  class MockKryptnosticEngine

    constructor: ({ @fhePrivateKey, @searchPrivateKey } = {}) ->

    # indexing
    # ========

    getObjectSearchKey: ->
      return BinaryUtils.stringToUint8(pad('doc.search'))

    getObjectAddressMatrix: ->
      return BinaryUtils.stringToUint8(pad('doc.addressfun'))

    getObjectIndexPair: ({ objectSearchKey, objectAddressMatrix }) ->
      return BinaryUtils.stringToUint8(pad('doc.index'))

    getMetadatumAddress: ({ objectAddressMatrix, objectSearchKey, token }) ->
      return BinaryUtils.stringToUint8('search.address.' + BinaryUtils.uint8ToString(token))

    # search
    # ======

    getEncryptedSearchToken: ({ token }) ->
      return BinaryUtils.stringToUint8(pad('search.token.' + BinaryUtils.uint8ToString(token)))

    # sharing
    # =======

    getObjectSharingPairFromObjectIndexPair: ({ objectIndexPair }) ->
      return BinaryUtils.stringToUint8('doc.sharing.' + BinaryUtils.uint8ToString(objectIndexPair))

    getObjectIndexPairFromObjectSharingPair: ({ objectSharingPair }) ->
      return BinaryUtils.stringToUint8('doc.upload.' + BinaryUtils.uint8ToString(objectUploadPair))

  return MockKryptnosticEngine
