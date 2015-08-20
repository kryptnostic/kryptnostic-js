define 'kryptnostic.kryptnostic-engine-adapter', [
  'require'
], (require) ->

  ENGINE_MISSING_ERROR = '''
    The KryptnosticEngine is unavailable. This component must be included separately, as it is not
    built as a part of the kryptnostic.js binary. Please see the krytpnostic.js documentation for
    more information.
  '''

  unless Module? and Module.KryptnosticEngine?
    throw new Error(ENGINE_MISSING_ERROR)

  #
  # Wrapper around the kryptnostic engine module produced by emscripten.
  # Author: rbuckheit
  #
  class KryptnosticEngine

    constructor: ->
      @engine = new Module.KryptnosticEngine()

    getPublicKey: ->
      return @engine.getPublicKey()

    getPrivateKey: ->
      return @engine.getPrivateKey()

    getServerSearchFunction: ->
      return @engine.getServerSearchFunction()

    getDocumentKey: (objectId) ->
      return @engine.getDocKey(objectId)

    getHashedToken: (token, documentKey) ->
      return @engine.getHashedToken(token, documentKey)

    getEncryptedSearchTerm: (objectId) ->
      return @engine.getEncryptedSearchTerm(objectId)

    setDocumentKey: (objectId, documentKey) ->
      return @engine.setDocumentKey(objectId, documentKey)

  return KryptnosticEngine
