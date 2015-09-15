define 'kryptnostic.caching-provider.locache', [
  'require'
  'locache'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'
  Cache = require 'locache'

  log = Logger.get('LocacheCachingProvider')

  #
  # Author: dbailey
  #
  class LocacheCachingProvider

    @cache = Cache

    @get: ( key ) ->
      @cache.get( key )

    @store: ( key, value ) ->
      @cache.set( key, value )

    @destroy: ->
      @cache.flush()
      @cache.cleanup()

  return LocacheCachingProvider
