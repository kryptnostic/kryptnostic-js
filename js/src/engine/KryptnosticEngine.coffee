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

    constructor: (@fhePrivateKey, @searchPrivateKey) ->

    # indexing
    # ========

    getObjectSearchKey: ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getObjectSearchKey()

    getObjectAddressFunction: ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getObjectAddressFunction()

    getObjectIndexPair: (objectSearchKey, objectAddressFunction) ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getObjectIndexPair(objectSearchKey, objectAddressFunction)

    getMetadatumAddress: (objectAddressFunction, token, objectSearchKey) ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getMetadatumAddress(objectAddressFunction, token, objectSearchKey)

    # search
    # ======

    getEncryptedSearchToken: (token) ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getEncryptedSearchToken(token)

    # share
    # =====

    getObjectSharingPair: (objectIndexPair) ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getObjectSharingPair(objectIndexPair)

    getObjectUploadPair: (objectSharingPair) ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey).getObjectUploadPair(objectSharingPair)

  return KryptnosticEngine
