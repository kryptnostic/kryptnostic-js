define 'kryptnostic.search-key-generator', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  log = Logger.get('SearchKeyGenerator')

  class SearchKeyGenerator

    # client keys
    # ===========
    getAllClientKeys: ->
      engine = new Module.KryptnosticClient()
      return {
        fhePrivateKey: engine.getPrivateKey()
        searchPrivateKey: engine.getSearchPrivateKey()
        clientHashFunction: engine.getClientHashFunction()
      }

  return SearchKeyGenerator
