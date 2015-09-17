define 'kryptnostic.kryptnostic-engine', [
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

  log = Logger.get('KryptnosticEngine')

  #
  # Wrapper around the kryptnostic client module produced by emscripten.
  # Author: rbuckheit
  #
  class KryptnosticEngine

    constructor: ({ @fhePrivateKey, @searchPrivateKey } = {}) ->
      unless Module? and Module.KryptnosticClient?
        log.error(ENGINE_MISSING_ERROR)

      if @fhePrivateKey and @searchPrivateKey
        @krypto = new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey)
      else
        @krypto = new Module.KryptnosticClient()

    #
    # registration
    #

    getPrivateKey: ->
      return @krypto.getPrivateKey()

    getSearchPrivateKey: ->
      return @krypto.getSearchPrivateKey()

    calculateClientHashFunction: ->
      # the client hash function is never used client-side; it only needs to be calculated on the
      # client and sent to the server. as such, we don't need to create a new Uint8Array.
      return @krypto.calculateClientHashFunction()

    #
    # indexing
    #

    generateObjectIndexPair: ->
      return new Uint8Array(@krypto.generateObjectIndexPair())

    calculateObjectSearchPairFromObjectIndexPair: (objectIndexPair) ->
      return new Uint8Array(@krypto.calculateObjectSearchPairFromObjectIndexPair(objectIndexPair))

    calculateMetadataAddress: (objectIndexPair, token) ->
      return new Uint8Array(@krypto.calculateMetadataAddress(objectIndexPair, token))

    #
    # searching
    #

    calculateEncryptedSearchToken: (token) ->
      return new Uint8Array(@krypto.calculateEncryptedSearchToken(token))

    #
    # sharing
    #

    calculateObjectSharePairFromObjectSearchPair: (objectSearchPair) ->
      return new Uint8Array(@krypto.calculateObjectSharePairFromObjectSearchPair(objectSearchPair))

    calculateObjectSearchPairFromObjectSharePair: (objectSharePair) ->
      return new Uint8Array(@krypto.calculateObjectSearchPairFromObjectSharePair(objectSharePair))

  return KryptnosticEngine
