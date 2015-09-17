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

    generateObjectIndexPair: ->
      return BinaryUtils.stringToUint8(pad('doc.search.doc.index'))

    calculateMetadataAddress: (objectIndexPair, token) ->
      return BinaryUtils.stringToUint8('search.address.' + BinaryUtils.uint8ToString(token))

  return MockKryptnosticEngine
