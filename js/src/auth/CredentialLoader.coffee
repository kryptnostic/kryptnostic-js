define 'kryptnostic.credential-loader', [
  'require'
  'kryptnostic.configuration'
  'kryptnostic.credential-provider-loader'
], (require) ->

  Config                   = require 'kryptnostic.configuration'
  CredentialProviderLoader = require 'kryptnostic.credential-provider-loader'

  class CredentialLoader

    @getCredentials: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.load()

  return CredentialLoader
