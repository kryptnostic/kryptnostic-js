define 'kryptnostic.chunking.registry', [
  'require'
  'kryptnostic.chunking.strategy.default'
  'kryptnostic.chunking.strategy.json'
  'kryptnostic.logger'
], (require) ->

  logger = require('kryptnostic.logger').get('ChunkingStrategyRegistry')

  DEFAULT_STRATEGY = 'kryptnostic.chunking.strategy.default'
  JSON_STRATEGY    = 'kryptnostic.chunking.strategy.json'

  STRATEGIES = [
    DEFAULT_STRATEGY,
    JSON_STRATEGY
  ]

  #
  # Provides access to chunking strategies supported by the client.
  # Strategies are keyed by a URI on the strategy class.
  # Strategies are keyed by the Java class name of the canonical implementation.
  #
  # Author: rbuckheit
  #
  class ChunkingStrategyRegistry

    @registry = {}

    @initialize : ->
      STRATEGIES.forEach (strategy) =>
        @register(require(strategy))

    @register : (strategyClass) ->
      unless strategyClass.URI and _.isString(strategyClass.URI)
        throw new Error('cannot register strategy class without a uri')
      strategyUri            = strategyClass.URI
      @registry[strategyUri] = strategyClass
      logger.info('registered', { strategyUri })

    @get : (strategyUri) ->
      if @registry[strategyUri]?
        return @registry[strategyUri]
      else
        logger.warn('unknown strategy, using default', { strategyUri })
        logger.info(JSON.stringify(@registry))
        return @registry[DEFAULT_STRATEGY]

  ChunkingStrategyRegistry.initialize()

  return ChunkingStrategyRegistry
