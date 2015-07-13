define 'soteria.credential-store', [
  'require'
], (require) ->

  #
  # Stores the user's credential provider once authenticated.
  # Author: rbuckheit
  #
  class CredentialStore

    @store: (credentialProvider) ->
      if @credentialProvider?
        throw new Error 'already authenticated'
      @credentialProvider = credentialProvider

    @destroy: ->
      if @credentialProvider?
        @credentialProvider.destroy()

    @isInitialized: ->
      return @credentialProvider?

  return CredentialStore

