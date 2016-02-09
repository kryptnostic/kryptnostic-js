define 'kryptnostic.caching-provider-loader', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.caching-provider.jscache'
  'kryptnostic.caching-provider.memory'
], (require) ->

  Logger  = require 'kryptnostic.logger'

  log = Logger.get('CachingProviderLoader')

  class CachingProviderLoader

    @load : (uri) ->

      # unfortunately, webpack gets angry if you try to require an expression, i.e., require(uri)
      if uri is 'kryptnostic.caching-provider.jscache'
        module = require('kryptnostic.caching-provider.jscache')
      else if uri is 'kryptnostic.caching-provider.memory'
        module = require('kryptnostic.caching-provider.memory')

      if module?
        return module
      else
        throw new Error 'failed to load caching provider for URI ' + uri
