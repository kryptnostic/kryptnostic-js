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

    constructor: ({ @fhePrivateKey, @searchPrivateKey }) ->

    # indexing
    # ========

    getObjectSearchKey: ->
      return BinaryUtils.stringToUint8(pad('doc.search'))

    getObjectAddressMatrix: ->
      return BinaryUtils.stringToUint8(pad('doc.addressfun'))

    getObjectIndexPair: ({ objectSearchKey, objectAddressMatrix }) ->
      return BinaryUtils.stringToUint8(pad('doc.index'))

    getMetadatumAddress: ({ objectAddressFunction, objectSearchKey, token }) ->
      return BinaryUtils.stringToUint8(pad('metadatum.address'))

    # search
    # ======

    getEncryptedSearchToken: ({ token }) ->
      return BinaryUtils.stringToUint8(pad('search.token.' + BinaryUtils.uint8ToString(token)))

    # share
    # =====

    getObjectSharingPair: ({ objectIndexPair }) ->
      return BinaryUtils.stringToUint8(pad('doc.sharing.' + BinaryUtils.uint8ToString(objectIndexPair)))

    getObjectIndexPairFromSharing: ({ objectSharingPair }) ->
      return BinaryUtils.stringToUint8(pad('doc.upload.' + BinaryUtils.uint8ToString(objectUploadPair)))

  return MockKryptnosticEngine
