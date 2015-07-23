define 'kryptnostic.chunking.registry', [
  'require'
  'kryptnostic.chunking.strategy.default'
  'kryptnostic.logger'
], (require) ->

  logger = require('kryptnostic.logger').get('ChunkingStrategyRegistry')

  DEFAULT_STRATEGY = 'kryptnostic.chunking.strategy.default'

  STRATEGIES = [
    DEFAULT_STRATEGY
  ]

  #
  # Provides access to chunking strategies supported by the client.
  # Strategies are keyed by a URI on the strategy class.
  #
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
      logger.info('registered', {strategyUri})

    @get : (strategyUri) ->
      if @registry[strategyUri]?
        logger.info('loaded', {strategyUri})
        return @registry[strategyUri]
      else
        logger.warn('unknown uri, returning default', {strategyUri, DEFAULT_STRATEGY})
        logger.info(JSON.stringify(@registry))
        return @registry[DEFAULT_STRATEGY]

  ChunkingStrategyRegistry.initialize()

  return ChunkingStrategyRegistry
