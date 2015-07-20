define 'soteria.credential-provider-loader', [
  'require'
  'soteria.logger'
  'soteria.credential-provider.memory'
  'soteria.credential-provider.local-storage'
  'soteria.credential-provider.session-storage'
], (require) ->

  Logger  = require 'soteria.logger'

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

