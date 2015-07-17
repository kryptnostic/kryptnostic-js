define 'soteria.credential-loader', [
  'require'
  'soteria.configuration'
  'soteria.credential-provider-loader'
], (require) ->

  Config                   = require 'soteria.configuration'
  CredentialProviderLoader = require 'soteria.credential-provider-loader'

  class CredentialLoader

    @getCredentials: ->
      credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
      return credentialProvider.load()

  return CredentialLoader
