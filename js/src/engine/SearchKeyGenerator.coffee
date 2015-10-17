define 'kryptnostic.search-key-generator', [
  'require'
  'kryptnostic.logger'
  'kryptnostic.kryptnostic-engine-provider'
], (require) ->

  # kryptnostic
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('SearchKeyGenerator')

  #
  # Generates client keys needed for search.
  #
  class SearchKeyGenerator

    generateClientKeys: ->
      engine = KryptnosticEngineProvider.getEngine()
      return {
        fhePrivateKey      : engine.getPrivateKey()
        searchPrivateKey   : engine.getSearchPrivateKey()
        clientHashFunction : engine.calculateClientHashFunction()
      }

  return SearchKeyGenerator
