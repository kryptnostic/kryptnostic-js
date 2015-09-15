define 'kryptnostic.caching-provider.memory', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  log = Logger.get('InMemoryCachingProvider')

  #
  # Author: dbailey
  #
  class InMemoryCachingProvider

    @cache = {}

    @store: ( key, value ) ->
      @cache[key] = value

    @get: ( key ) ->
      value = @cache[key]
      if value?
        return value
      return null

    @destroy: ->
      @cache = {}

  return InMemoryCachingProvider
