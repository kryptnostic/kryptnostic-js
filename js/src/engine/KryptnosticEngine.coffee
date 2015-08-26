define 'kryptnostic.kryptnostic-engine', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  ENGINE_MISSING_ERROR = '''
    The KryptnosticClient engine is unavailable. This component must be included separately.
    It is not built as a part of the kryptnostic.js binary. Please see the krytpnostic.js
    documentation for more information and/or file an issue on the kryptnostic-js github project:
    https://github.com/kryptnostic/kryptnostic-js/issues
  '''

  log = Logger.get('KryptnosticEngine')

  #
  # Wrapper around the kryptnostic engine module produced by emscripten.
  # Author: rbuckheit
  #
  class KryptnosticEngine

    constructor: ->
      if Module? and Module.KryptnosticClient?
        @engine = new Module.KryptnosticClient()
        log.info('instantiated engine', @engine)
        log.info(@engine)
      else
        log.error(ENGINE_MISSING_ERROR)
        @engine = undefined

    # client keys
    # ===========

    getFhePrivateKey: ->
      log.info('use engine', @engine)
      log.info(@engine)
      return @engine.getPrivateKey()

    getSearchPrivateKey: ->
      return @engine.getSearchPrivateKey()

    getClientHashFunction: ->
      return @engine.getClientHashFunction()

    # indexing
    # ========

    getObjectSearchKey: (id) ->
      return @engine.getObjectSearchKey(id)

    getObjectAddressFunction: (id) ->
      return @engine.getObjectAddressFunction(id)

    getObjectConversionMatrix: (id) ->
      return @engine.getObjectConversionMatrix(id)

    getObjectIndexPair: (id) ->
      return @engine.getObjectIndexPair(id)

    getObjectSharingPair: (id) ->
      return @engine.getObjectSharingPair(id)

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return @engine.getEncryptedSearchToken(token)

    getTokenAddress: (token, documentKey) ->
      throw new Error 'unimplemented'

  return KryptnosticEngine
