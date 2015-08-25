define 'kryptnostic.kryptnostic-engine', [
  'require'
], (require) ->

  ENGINE_MISSING_ERROR = '''
    The KryptnosticClient engine is unavailable. This component must be included separately.
    It is not built as a part of the kryptnostic.js binary. Please see the krytpnostic.js
    documentation for more information and/or file an issue on the kryptnostic-js github project:
    https://github.com/kryptnostic/kryptnostic-js/issues
  '''

  unless Module? and Module.KryptnosticClient?
    throw new Error(ENGINE_MISSING_ERROR)

  #
  # Wrapper around the kryptnostic engine module produced by emscripten.
  # Author: rbuckheit
  #
  class KryptnosticEngine

    constructor: ->
      @engine = new Module.KryptnosticClient()

    # client keys
    # ===========

    getFhePrivateKey: ->
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
