define 'soteria.chunking.registry', [
  'require'
  'soteria.chunking.strategy.default'
], (require) ->

  DEFAULT_STRATEGY = 'soteria.chunking.strategy.default'

  STRATEGIES = [
    DEFAULT_STRATEGY
  ]

  #
  # Provides access to chunking strategies supported by the client.
  # Strategies are keyed by a URI on the strategy class.
  # Author: rbuckheit
  #
  class ChunkingStrategyRegistry

    @registry : {}

    @initialize : ->
      STRATEGIES.forEach (strategy) =>
        @register(require(strategy))

    @register : (strategyClass) ->
      unless strategyClass.URI and _.isString(strategyClass.URI)
        throw new Error('cannot register strategy class without a uri')
      strategyUri            = strategyClass.URI
      @registry[strategyUri] = strategyClass
      console.info("[ChunkingStrategyRegistry] registered: '#{strategyUri}'")

    @get : (strategyUri) ->
      if @registry[strategyUri]?
        console.info("[ChunkingStrategyRegistry] loaded: '#{strategyUri}'")
        return @registry[strategyUri]
      else
        console.warn("[ChunkingStrategyRegistry] unknown uri '#{strategyUri}' returning default '#{DEFAULT_STRATEGY}'")
        console.info(JSON.stringify(@registry))
        return @registry[DEFAULT_STRATEGY]

  ChunkingStrategyRegistry.initialize()

  return ChunkingStrategyRegistry
