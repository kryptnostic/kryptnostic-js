define 'kryptnostic.search-key-generator', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  ENGINE_MISSING_ERROR = '''
    KryptnosticClient is unavailable. This component must be included separately.
    It is not built as a part of the kryptnostic.js binary. Please see the krytpnostic.js
    documentation for more information and/or file an issue on the kryptnostic-js github project:
    https://github.com/kryptnostic/kryptnostic-js/issues
  '''

  log = Logger.get('SearchKeyGenerator')

  #
  # Generates client keys needed for search.
  #
  class SearchKeyGenerator

    constructor: ->
      unless Module? and Module.KryptnosticClient?
        log.error(ENGINE_MISSING_ERROR)

    generateClientKeys: ->
      engine = new Module.KryptnosticClient()
      return {
        fhePrivateKey      : engine.getPrivateKey()
        searchPrivateKey   : engine.getSearchPrivateKey()
        clientHashFunction : engine.getClientHashFunction()
      }

  return SearchKeyGenerator
