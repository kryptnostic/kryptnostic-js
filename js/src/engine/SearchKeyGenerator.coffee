define 'kryptnostic.search-key-generator', [
  'require'
], (require) ->

  #
  # Generates client keys needed for search.
  #
  class SearchKeyGenerator

    generateClientKeys: ->
      engine = new Module.KryptnosticClient()
      return {
        fhePrivateKey      : engine.getPrivateKey()
        searchPrivateKey   : engine.getSearchPrivateKey()
        clientHashFunction : engine.getClientHashFunction()
      }

  return SearchKeyGenerator
