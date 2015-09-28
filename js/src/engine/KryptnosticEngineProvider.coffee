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
      _engine ?= new KryptnosticEngine({ @fhePrivateKey, @searchPrivateKey })

    @getEngine: ->
      if _engine?
        return _engine
      else
        return @init()

  return KryptnosticEngineProvider
