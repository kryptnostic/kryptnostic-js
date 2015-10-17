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

  logger = Logger.get('KryptnosticEngine')

  #
  # wrapper around the KryptnosticClient module produced by emscripten
  #
  class KryptnosticEngine

    constructor: ({ @fhePrivateKey, @searchPrivateKey } = {}) ->
      unless Module? and Module.KryptnosticClient?
        logger.error(ENGINE_MISSING_ERROR)

      if @fhePrivateKey and @searchPrivateKey
        @krypto = new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey)
      else
        @krypto = new Module.KryptnosticClient()

    #
    # registration
    #

    getPrivateKey: ->
      return new Uint8Array(@krypto.getPrivateKey())

    getSearchPrivateKey: ->
      return new Uint8Array(@krypto.getSearchPrivateKey())

    calculateClientHashFunction: ->
      return new Uint8Array(@krypto.calculateClientHashFunction())

    #
    # indexing
    #

    generateObjectIndexPair: ->
      return new Uint8Array(@krypto.generateObjectIndexPair())

    calculateMetadataAddress: (objectIndexPair, token) ->
      return new Uint8Array(@krypto.calculateMetadataAddress(objectIndexPair, token))

    calculateObjectSearchPairFromObjectIndexPair: (objectIndexPair) ->
      return new Uint8Array(@krypto.calculateObjectSearchPairFromObjectIndexPair(objectIndexPair))

    calculateObjectIndexPairFromObjectSearchPair: (objectSearchPair) ->
      return new Uint8Array(@krypto.calculateObjectIndexPairFromObjectSearchPair(objectSearchPair))

    #
    # searching
    #

    calculateEncryptedSearchToken: (tokenAsUint8) ->
      return new Uint8Array(@krypto.calculateEncryptedSearchToken(tokenAsUint8))

    #
    # sharing
    #

    calculateObjectSharePairFromObjectSearchPair: (objectSearchPair) ->
      return new Uint8Array(@krypto.calculateObjectSharePairFromObjectSearchPair(objectSearchPair))

    calculateObjectSearchPairFromObjectSharePair: (objectSharePair) ->
      return new Uint8Array(@krypto.calculateObjectSearchPairFromObjectSharePair(objectSharePair))

  return KryptnosticEngine
