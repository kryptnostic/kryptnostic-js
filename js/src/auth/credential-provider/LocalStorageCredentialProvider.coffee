define 'kryptnostic.credential-provider.local-storage', [
  'require'
  'kryptnostic.credential-provider.key-value'
], (require) ->

  KeyValueCredentialProvider = require 'kryptnostic.credential-provider.key-value'

  #
  # Credential provider which stores credentials in local storage.
  # Author: rbuckheit
  #
  class LocalStorageCredentialProvider

    @delegate : window.localStorage

    @store: ({ principal, credential, keypair }) ->
      return KeyValueCredentialProvider.store(@delegate, { principal, credential, keypair })

    @load: ->
      return KeyValueCredentialProvider.load(@delegate)

    @destroy: ->
      return KeyValueCredentialProvider.destroy(@delegate)

  return LocalStorageCredentialProvider
