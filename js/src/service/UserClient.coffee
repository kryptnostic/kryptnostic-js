define 'kryptnostic.user-client', [
  'require'
  'bluebird'
  'jscache'
  'kryptnostic.logger'
  'kryptnostic.user-directory-api'
], (require) ->

  Cache            = require 'jscache'
  Promise          = require 'bluebird'
  Logger           = require 'kryptnostic.logger'
  UserDirectoryApi = require 'kryptnostic.user-directory-api'

  log              = Logger.get('UserClient')

  MAX_CACHED_USERS = 500

  CACHE_TIMEOUT_MILLIS = 1000 * 60 * 60 * 8 # 8 hours

  getCacheOpts = ->
    return {
      expirationAbsolute : new Date(new Date().getTime() + CACHE_TIMEOUT_MILLIS)
      expirationSliding  : undefined
      priority           : Cache.Priority.HIGH
      callback           : (k, v) -> log.info('expired cached user', k)
    }

  #
  # Service for loading user data.
  # Author: rbuckheit
  #
  class UserClient

    constructor: ->
      @userDirectoryApi = new UserDirectoryApi()
      @cache            = new Cache(MAX_CACHED_USERS)

    # load full user representation
    loadUser: (uuid) ->
      Promise.resolve()
      .then =>
        cacheItem = @cache.getItem(uuid)

        if cacheItem?
          log.info('hit: returning cached user', { uuid })
          return cacheItem
        else
          log.info('miss: loading user', { uuid })
          promise = @userDirectoryApi.getUser(uuid)
          @cache.setItem(uuid, promise, getCacheOpts())
          return promise

    # load the user's name only
    loadName : (uuid) ->
      Promise.resolve()
      .then =>
        @loadUser(uuid)
      .then (user) ->
        return user.name

  return UserClient
