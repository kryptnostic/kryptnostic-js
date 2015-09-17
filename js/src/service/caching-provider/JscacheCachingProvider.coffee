define 'kryptnostic.caching-provider.jscache', [
  'require'
  'jscache'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'
  Cache  = require 'jscache'

  log = Logger.get('JsCacheCachingProvider')

  MAX_CACHED_OBJECTS = 500

  CACHE_TIMEOUT_MILLIS = 1000 * 60 * 60 * 8 # 8 hours

  getCacheOpts = ->
    return {
      expirationAbsolute : new Date(new Date().getTime() + CACHE_TIMEOUT_MILLIS)
      expirationSliding  : undefined
      priority           : Cache.Priority.HIGH
      callback           : (k, v) -> log.info('expired cached user', k)
    }

  #
  # Author: dbailey
  #
  class JscacheCachingProvider

    @cache = {} # new Cache(MAX_CACHED_OBJECTS)

    @store: ( group, key, value ) ->
      if !@cache[group]?
        @cache[group] = new Cache(MAX_CACHED_OBJECTS)
      @cache[group].setItem( key, value, getCacheOpts() )

    @get: ( group, key ) ->
      if @cache[group]?
        value = @cache[group].getItem( key )
        return value
      return null

    @destroy: ->
      for k, v of @cache
        v.clear()
      @cache = {}

  return JscacheCachingProvider
