define 'kryptnostic.kryptnostic-engine-adapter', [
  'require'
  'kryptnostic-engine'
], (require) ->

  class KryptnosticEngineAdapter

    constructor: ->
      @engine = new Module.KryptnosticEngine()

  return KryptnosticEngineAdapter
