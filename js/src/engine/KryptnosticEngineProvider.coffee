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

    @init: ({ @fhePrivateKey, @searchPrivateKey } = {}) ->
      logger.debug('initializing KryptnosticEngine with keys')
      _engine ?= new KryptnosticEngine({ @fhePrivateKey, @searchPrivateKey })

    @getEngine: ->
      if _engine?
        return _engine
      else
        logger.debug('initializing a new KryptnosticEngine without keys...')
        return @init()

  return KryptnosticEngineProvider
