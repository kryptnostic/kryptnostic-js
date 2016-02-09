define 'kryptnostic.caching-provider-loader', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.caching-provider.jscache'
  'kryptnostic.caching-provider.memory'
], (require) ->

  Logger  = require 'kryptnostic.logger'

  log = Logger.get('CachingProviderLoader')

  #
  # Loads caching providers by their module uri.
  # Author: dbailey
  #
  class CachingProviderLoader

    @load : (uri) ->

      if uri is 'kryptnostic.caching-provider.jscache'
        module = require('kryptnostic.caching-provider.jscache')
      else if uri is 'kryptnostic.caching-provider.memory'
        module = require('kryptnostic.caching-provider.memory')

      if module?
        return module
      else
        throw new Error 'failed to load caching provider for URI ' + uri
