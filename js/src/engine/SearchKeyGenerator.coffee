define 'kryptnostic.search-key-generator', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.kryptnostic-engine'
], (require) ->

  Logger            = require 'kryptnostic.logger'
  KryptnosticEngine = require 'kryptnostic.kryptnostic-engine'

  log = Logger.get('SearchKeyGenerator')

  #
  # Generates client keys needed for search.
  #
  class SearchKeyGenerator

    constructor: ->
      @engine = new KryptnosticEngine()

    generateClientKeys: ->
      return {
        fhePrivateKey      : engine.getPrivateKey()
        searchPrivateKey   : engine.getSearchPrivateKey()
        clientHashFunction : engine.calculateClientHashFunction()
      }

  return SearchKeyGenerator
