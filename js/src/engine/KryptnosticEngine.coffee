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
      unless Module? and Module.KryptnosticClient?
        log.error(ENGINE_MISSING_ERROR)

    # client keys
    # ===========

    getFhePrivateKey: ->
      return new Module.KryptnosticClient().getPrivateKey()

    getSearchPrivateKey: ->
      return new Module.KryptnosticClient().getSearchPrivateKey()

    getClientHashFunction: ->
      return new Module.KryptnosticClient().getClientHashFunction()

    # indexing
    # ========

    getObjectSearchKey: (id) ->
      return new Module.KryptnosticClient().getObjectSearchKey(id)

    getObjectAddressFunction: (id) ->
      return new Module.KryptnosticClient().getObjectAddressFunction(id)

    getObjectConversionMatrix: (id) ->
      return new Module.KryptnosticClient().getObjectConversionMatrix(id)

    getObjectIndexPair: (id) ->
      return new Module.KryptnosticClient().getObjectIndexPair(id)

    getObjectSharingPair: (id) ->
      return new Module.KryptnosticClient().getObjectSharingPair(id)

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return new Module.KryptnosticClient().getEncryptedSearchToken(token)

    getTokenAddress: (token, documentKey) ->
      throw new Error 'unimplemented'

  return KryptnosticEngine
