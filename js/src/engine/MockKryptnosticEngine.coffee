define 'kryptnostic.mock.fhe-engine', [
  'require'
], (require) ->

  # explode a string to a binary array of bytes.
  explode = (string) ->
    return new Uint8Array(string.map((c) -> c.charCodeAt()))

  implode = (uint8array) ->
    uint8array.map((byte) -> String.fromCharCode(byte)).join()

  #
  # Stand-in for the FHE engine which returns mocked values.
  # This class intentionally does not provide any security.
  #
  # Author: rbuckheit
  #
  class MockKryptnosticEngine

    # fhe keys
    # ========

    getFhePublicKey: ->
      return explode('fhe.pub')

    getFhePrivateKey: ->
      return explode('fhe.pvt')

    # search keys
    # ===========

    getFheSearchPublicKey: ->
      return explode('search..pub')

    getFheSearchPrivateKey: ->
      return explode('search.pvt')

    # client hash function
    # ====================

    getClientHashFunctionHashMatrix: ->
      return explode('hf.hashmatrix')

    getClientHashFunctionAugmented: ->
      return explode('hf.augmented')

    getClientHashConcealed: ->
      return explode('hf.concealed')

    # document search keys
    # ====================

    getDocumentSearchKey: (id) ->
      return explode('d' + id)

    # address functions
    # =================

    getDocumentAddressFunction: (id) ->
      return explode('a' + id)

    # ???: what does this actually take as arguments?
    getDocumentConversionMatrix: (id) ->
      return explode('m' + id)

    # token transformations
    # =====================

    # hash a token with MurmurHash128 (for use when indexing).
    # ???: what does this actually take as arguments?
    getHashedToken: (token) ->
      return explode('h' + token)

    # produce an encrypted search term, which can be submitted as a query.
    # ???: what does this actually take as arguments?
    getEncryptedSearchTerm: (token) ->
      return explode('s' + token)

    # compute address on the server for a token
    getTokenAddress: (token, addressFunction) ->
      return explode(token + implode(addressFunction))

    # sharing
    # =======

    # ???: what does this take as arguments?
    getConversationMatrix: (addressFunction, someOtherThing) ->

  return MockKryptnosticEngine
