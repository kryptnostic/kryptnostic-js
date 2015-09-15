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

    @store: ( group, key, value ) ->
      if !@cache[group]?
        @cache[group] = {}
      @cache[group][key] = value

    @get: ( group, key ) ->
      if @cache[group]?
        value = @cache[group][key]
      if value?
        return value
      return null

    @destroy: ->
      @cache = {}

  return InMemoryCachingProvider
