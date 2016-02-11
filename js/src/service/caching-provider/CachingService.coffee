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

    @USERS                 = 'users'
    @UUIDS                 = 'uuids'
    @SALTS                 = 'user_salts'
    @OBJECTS               = 'objects'
    @PUBLIC_KEYS           = 'public_keys'
    @DEFAULT_GROUP         = 'default_group'
    @CRYPTO_SERVICES       = 'object_crypto_services'

    @MASTER_AES_CRYPTO_SERVICE           = 'master_aes_crypto_service'
    @MASTER_AES_CRYPTO_SERVICE_ENCRYPTED = 'master_aes_crypto_service_encrypted'

    # store something in the cache
    @store: ( group, key, value ) ->
      if !group? || !key? || !value?
        throw new Error 'Bad arguments to store cache!' + group + ', ' + key + ', ' + value
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      log.debug( 'Cached ' + group + ': ' + key + ', ' + JSON.stringify(value) )
      cache.store( group, key, value )

    @get: ( group, key ) ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      cached = cache.get( group, key )
      if cached?
        log.debug( 'Cache hit: ' + group + ', ' + key + ': ' + JSON.stringify(cached) )
      else
        log.debug( 'Cache miss: ' + group + ', ' + key )
      return cached

    # search for a set of keys in a particular group
    # returns an object:
    #   { uncached: [uncachedKeys], cached: [cachedObjects] }
    @search: ( group, keys ) ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      results = {}
      results['uncached'] = []
      results['cached'] = []

      if _.isEmpty(keys)
        return results

      for key in keys
        cached = cache.get( group, key )
        if cached?
          list = results['cached']
          list.push(cached)
          results['cached'] = list
          log.debug('search hit: ' + group + ', ' + key)
        else
          uncached = results['uncached']
          uncached.push(key)
          results['uncached'] = uncached
          log.debug('search miss: ' + group + ', ' + key)
      return results

    @destroy: ->
      cache = CachingProviderLoader.load(Config.get('cachingProvider'))
      return cache.destroy()

  return CachingService
