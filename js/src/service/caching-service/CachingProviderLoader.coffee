define 'kryptnostic.caching-provider-loader', [
  'require'
  'kryptnostic.logger'
  # 'kryptnostic.caching-provider.locache'
  'kryptnostic.caching-provider.jscache'
  'kryptnostic.caching-provider.memory'
  # 'kryptnostic.caching-provider.local-storage'
  # 'kryptnostic.caching-provider.session-storage'
], (require) ->

  Logger  = require 'kryptnostic.logger'

  log = Logger.get('CachingProviderLoader')

  #
  # Loads caching providers by their module uri.
  # Author: dbailey
  #
  class CachingProviderLoader

    @load : (uri) ->
      module = require(uri)

      if module?
        return module
      else
        throw new Error 'failed to load caching provider for URI ' + uri

