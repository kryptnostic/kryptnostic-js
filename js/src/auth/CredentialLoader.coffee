define 'kryptnostic.credential-loader', [
  'require'
  'kryptnostic.configuration'
  'kryptnostic.credential-provider-loader'
], (require) ->

  Logger                   = require 'kryptnostic.logger'
  Config                   = require 'kryptnostic.configuration'
  CredentialProviderLoader = require 'kryptnostic.credential-provider-loader'

  log = Logger.get('CredentialLoader')

  class CredentialLoader

    getCredentials: ->
      providerUri        = Config.get('credentialProvider')
      credentialProvider = CredentialProviderLoader.load(providerUri)
      return credentialProvider.load()

  return CredentialLoader
