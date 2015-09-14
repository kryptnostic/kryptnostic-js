define 'kryptnostic.caching-provider.local-storage', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  log = Logger.get('LocalStorageCachingProvider')

  #
  # Author: dbailey
  #
  class LocalStorageCachingProvider


  return LocalStorageCachingProvider
