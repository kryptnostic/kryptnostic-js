define 'kryptnostic.credential-provider.session-storage', [
  'require'
  'kryptnostic.credential-provider.key-value'
], (require) ->

  KeyValueCredentialProvider = require 'kryptnostic.credential-provider.key-value'

  #
  # Credential provider which stores credentials in session storage.
  # Author: rbuckheit
  #
  class SessionStorageCredentialProvider

    @delegate : window.sessionStorage

    @store: ({ principal, credential, keypair }) ->
      return KeyValueCredentialProvider.store(@delegate, { principal, credential, keypair })

    @load: ->
      return KeyValueCredentialProvider.load(@delegate)

    @destroy: ->
      return KeyValueCredentialProvider.destroy(@delegate)

  return SessionStorageCredentialProvider
