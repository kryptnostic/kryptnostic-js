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

    constructor: ({ @fhePrivateKey, @searchPrivateKey }) ->
      unless Module? and Module.KryptnosticClient?
        log.error(ENGINE_MISSING_ERROR)

    createClient: ->
      return new Module.KryptnosticClient(@fhePrivateKey, @searchPrivateKey)

    # indexing
    # ========

    getObjectSearchKey: ->
      return @createClient().getObjectSearchKey()

    getObjectAddressMatrix: ->
      return @createClient().getObjectAddressMatrix()

    getObjectIndexPair: ({ objectSearchKey, objectAddressMatrix }) ->
      return @createClient().getObjectIndexPair(objectSearchKey, objectAddressMatrix)

    getMetadatumAddress: ({ objectAddressFunction, token, objectSearchKey }) ->
      return @createClient().getMetadatumAddress(objectAddressFunction, objectSearchKey, token)

    # search
    # ======

    getEncryptedSearchToken: ({ token }) ->
      return @createClient().getEncryptedSearchToken(token)

    # sharing
    # =======

    getObjectSharingPair: ({ objectIndexPair }) ->
      return @createClient().getObjectSharingPair(objectIndexPair)

    getObjectIndexPairFromSharing: ({ objectSharingPair }) ->
      return @createClient().getObjectUploadPair(objectSharingPair)

  return KryptnosticEngine
