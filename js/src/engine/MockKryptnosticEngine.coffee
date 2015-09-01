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

    constructor: (@fhePrivateKey, @searchPrivateKey) ->

    # indexing
    # ========

    getObjectSearchKey: ->
      return BinaryUtils.stringToUint8(pad('doc.search'))

    getObjectAddressFunction: ->
      return BinaryUtils.stringToUint8(pad('doc.addressfun'))

    getObjectIndexPair: (objectSearchKey, objectAddressFunction) ->
      return BinaryUtils.stringToUint8(pad('doc.index'))

    getMetadatumAddress: (objectAddressFunction, token, objectSearchKey) ->
      return BinaryUtils.stringToUint8(pad('metadatum.address'))

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return BinaryUtils.stringToUint8(pad('search.token.' + BinaryUtils.uint8ToString(token)))

    # share
    # =====

    getObjectSharingPair: (objectIndexPair) ->
      return BinaryUtils.stringToUint8(pad('doc.sharing.' + BinaryUtils.uint8ToString(objectIndexPair)))

    getObjectUploadPair: (objectSharingPair) ->
      return BinaryUtils.stringToUint8(pad('doc.upload.' + BinaryUtils.uint8ToString(objectUploadPair)))

  return MockKryptnosticEngine
