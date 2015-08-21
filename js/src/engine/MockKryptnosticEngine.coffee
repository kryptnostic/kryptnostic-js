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

    getFheSearchPublicKey: ->
      return explode('search.pub')

    getFheSearchPrivateKey: ->
      return explode('search.pvt')

    getClientHashFunction: ->
      return explode('client.hash')

    # indexing
    # ========

    getDocumentAddressFunction: (id) ->
      return explode('doc.address')

    getDocumentConversionMatrix: (id) ->
      return explode('doc.conversion')

    getDocumentSearchKey: (id) ->
      return explode('doc.search')

    getDocumentIndexPair: (id) ->
      return explode('doc.index')

    # pair of { docSearchKey, docAddressFunction }
    getDocumentSharingPair: (id) ->
      return explode('doc.sharing')

    # search
    # ======

    # produce an encrypted search term, which can be submitted as a query.
    getEncryptedSearchTerm: (token) ->
      return explode('search.token.' + collapse(token))

    # compute address on the server for a token
    getTokenAddress: (token, documentKey) ->
      return explode('search.address.' + collapse(token))

    # sharing
    # =======

  return MockKryptnosticEngine
