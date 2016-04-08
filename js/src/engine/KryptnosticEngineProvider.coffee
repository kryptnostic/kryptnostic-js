define 'kryptnostic.kryptnostic-engine-provider', [
  'require'
  'kryptnostic.kryptnostic-engine'
  'kryptnostic.logger'
], (require) ->

  KryptnosticEngine = require 'kryptnostic.kryptnostic-engine'
  Logger            = require 'kryptnostic.logger'

  logger = Logger.get('KryptnosticEngineProvider')

  class KryptnosticEngineProvider

    _engine = null

    @init: ({ @fhePrivateKey, @fheSearchPrivateKey } = {}) ->
      logger.debug('initializing KryptnosticEngine')
      if _engine?
        throw new Error('KryptnosticEngine has already been initialized')
      _engine ?= new KryptnosticEngine({ @fhePrivateKey, @fheSearchPrivateKey })
      return

    @getEngine: ->
      if _engine?
        return _engine
      throw new Error('KryptnosticEngine has not been initialized')

    @destroy: ->
      _engine.krypto.delete()
      _engine = null
      return

  return KryptnosticEngineProvider
