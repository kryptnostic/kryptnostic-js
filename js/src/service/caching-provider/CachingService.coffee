define 'kryptnostic.caching-service', [
  'require'
  'lodash'
  'kryptnostic.configuration'
  'kryptnostic.caching-provider-loader'
  'kryptnostic.logger'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  Config                = require 'kryptnostic.configuration'
  CachingProviderLoader = require 'kryptnostic.caching-provider-loader'

  log                   = Logger.get('CachingService')

  #
  # Author: dbailey
  #
  class CachingService

    # store something in the cache
    @store: ( key, value ) ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      log.error( 'Cached ' + key + ', ' + value )
      cache.store( key, value )

    @get: ( key ) ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      log.error( 'Get ' + key )
      cache.get( key )

    @destroy: ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      return cache.destroy()

  return CachingService
