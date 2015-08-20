define 'kryptnostic.kryptnostic-engine-adapter', [
  'require'
  'kryptnostic-engine'
], (require) ->

  #
  # Wrapper around the kryptnostic engine.
  # Author: rbuckheit
  #
  class KryptnosticEngineAdapter

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

  return KryptnosticEngineAdapter
