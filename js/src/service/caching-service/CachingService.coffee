define 'kryptnostic.caching-service', [
  'require'
  'lodash'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.caching-provider-loader'
  'kryptnostic.logger'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  Config                = require 'kryptnostic.configuration'
  Promise               = require 'bluebird'
  CachingProviderLoader = require 'kryptnostic.caching-provider-loader'

  log                   = Logger.get('CachingService')

  #
  # Author: dbailey
  #
  class CachingService

    constructor: ->
      cacheImpl = CachingProviderLoader.load(Config.get('cachingProvider'))
      @cache = new cacheImpl()

    # store something in the cache
    @store: ( key, value, type ) ->
      Promise.resolve()
      .then =>
        @cache.store( key, value, type )
      .then ->
        log.info( 'Cached ' + key + ', ' + value + ' with type ' + type )

    @get: ( key ) ->
      Promise.resolve()
      .then =>
        item = @cache.get( key )

    @getAndLoad: ( key, loader ) ->
      Promise.resolve()
      .then =>
        item = @cache.get( key )
        if item?
          log.info('hit: returning cached item', { key } )
          return item
        else
          log.info('miss: loading item', { key })
          promise = loader()
          @cache.store( key, promise )
          return promise

    @destroy: ->
      return @cache.destroy()

  return CachingService
