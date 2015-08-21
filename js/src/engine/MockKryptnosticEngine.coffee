define 'kryptnostic.mock.fhe-engine', [
  'require'
], (require) ->

  # explode a string to a binary array.
  explode = (string) ->
    return new Uint8Array(_.map(string, (c) -> c.charCodeAt()))

  # collapse a binary array into a string.
  implode = (uint8array) ->
    uint8array.map((byte) -> String.fromCharCode(byte)).join()

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
      return explode('search.token')

    # compute address on the server for a token
    getTokenAddress: (token, documentKey) ->
      return explode('search.address')

    # sharing
    # =======

  return MockKryptnosticEngine
