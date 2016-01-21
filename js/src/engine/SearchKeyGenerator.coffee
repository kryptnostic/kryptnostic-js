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
        FHE_PRIVATE_KEY        : engine.getPrivateKey()
        FHE_SEARCH_PRIVATE_KEY : engine.getSearchPrivateKey()
        FHE_HASH_FUNCTION      : engine.calculateClientHashFunction()
      }

  return SearchKeyGenerator
