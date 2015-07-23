define 'kryptnostic.credential-provider-loader', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.credential-provider.memory'
  'kryptnostic.credential-provider.local-storage'
  'kryptnostic.credential-provider.session-storage'
], (require) ->

  Logger  = require 'kryptnostic.logger'

  log = Logger.get('CredentialProviderLoader')

  #
  # Loads credential providers by their module uri.
  # Author: rbuckheit
  #
  class CredentialProviderLoader

    @load : (uri) ->
      module = require(uri)

      if module?
        return module
      else
        throw new Error 'failed to load credential provider for URI ' + uri

