define 'kryptnostic.kryptnostic-engine-provider', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  log = Logger.get('KryptnosticEngineProvider')

  class KryptnosticEngineProvider

    @setEngine: (kryptnosticEngine) ->
      @engine = kryptnosticEngine

    @getEngine: ->
      return @engine

  return KryptnosticEngineProvider
