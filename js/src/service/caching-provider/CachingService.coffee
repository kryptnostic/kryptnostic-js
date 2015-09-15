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

    @USERS           = 'users'
    @SALTS           = 'user_salts'
    @PUBLIC_KEYS     = 'public_keys'
    @DEFAULT_GROUP   = 'default_group'
    @CRYPTO_SERVICES = 'object_crypto_services'

    # store something in the cache
    @store: ( group, key, value ) ->
      if !group? || !key? || !value?
        throw new Error 'Bad arguments to store cache!' + group + ', ' + key + ', ' + value
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      log.info( 'Cached ' + key + ', ' + value + 'under group ' + group )
      cache.store( group, key, value )

    @get: ( group, key ) ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      cached = cache.get( group, key )
      if cached?
        log.info( 'Cache hit: ' + key )
      else
        log.info( 'Cache miss: ' + key )
      return cached

    @destroy: ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      return cache.destroy()

  return CachingService
