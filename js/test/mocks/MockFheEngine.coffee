define 'kryptnostic.mock.fhe-engine', [
  'require'
], (require) ->

  #
  # Substitute for the FHE engine which returns mocked values.
  # Author: rbuckheit
  #
  class MockFheEngine

    # @return a string representation the address in memory where the document is stored.
    mapTokenToIndex : ({ token, sharingKey }) ->
      return "mock-token-index-#{token}"

    # @return a string representation of the bridge key for the sharing key.
    getBridgeKey : ({ sharingKey }) ->
      return "mock-bridge-key-#{sharingKey}"

    # @return a string representation of the encrypted token (word)
    getEncryptedSearchTerm : ({ token }) ->
      return "mock-encrypted-token-#{token}"

    # @return a sharingKey for the object
    generateSharingKey : ({ id }) ->
      return "mock-sharing-key-#{id}"

  return MockFheEngine
