# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.kryptnostic-workers-api', [
  'require',
  'forge',
  'kryptnostic.logger'
], (require) ->

  # libraries
  forge = require 'forge'

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('KryptnosticWorkersApi')

  #
  # internal classes
  #

  class KryptnosticWorker

    constructor: ->
      @scriptUrl = null
      @webWorker = null

    start: ->

      logger.info('worker script url: ' + @scriptUrl)

      if _.isEmpty(@scriptUrl)
        return

      @webWorker = new Worker(@scriptUrl)
      @webWorker.postMessage({})

    terminate: ->

      if not @webWorker
        return

      @webWorker.terminate()
      @webWorker = null
      @scriptUrl = null

    query: ->

      if not @webWorker
        return

      @webWorker.postMessage({
        query: true
      })

  class FHEKeysGenerationWorker extends KryptnosticWorker

    constructor: ->
      super()

    query: ->

      if not @webWorker
        return

      return new Promise (resolve, reject) =>

        # handle query response
        @webWorker.onmessage = (messageEvent) ->

          fheKeys = null
          if messageEvent and messageEvent.data
            fheKeys = messageEvent.data

          if fheKeys?
            resolve(fheKeys)
          else
            resolve(null)

        # execute query
        super()
        return

  class RSAKeysGenerationWorker extends KryptnosticWorker

    constructor: ->
      super()

    query: ->

      if not @webWorker
        return

      return new Promise (resolve, reject) =>

        # handle query response
        @webWorker.onmessage = (messageEvent) ->

          rsaKeyPair = null
          if messageEvent and messageEvent.data
            rsaKeyPair = messageEvent.data

          if rsaKeyPair?
            publicKey = new forge.util.ByteBuffer(rsaKeyPair.publicKey)
            privateKey = new forge.util.ByteBuffer(rsaKeyPair.privateKey)
            resolve({
              publicKey,
              privateKey
            })
          else
            resolve(null)

        # execute query
        super()
        return

  #
  # external API for interacting with web workers
  #

  class KryptnosticWorkersApi

    # static constants
    @FHE_KEYS_GEN_WORKER = 'FHE_KEYS_GEN_WORKER'
    @RSA_KEYS_GEN_WORKER = 'RSA_KEYS_GEN_WORKER'

    WORKERS = {
      FHE_KEYS_GEN_WORKER: new FHEKeysGenerationWorker()
      RSA_KEYS_GEN_WORKER: new RSAKeysGenerationWorker()
    }

    @setWorkerUrl: (workerKey, workerScriptUrl) ->

      if not WORKERS[workerKey] or _.isEmpty(workerScriptUrl)
        return

      WORKERS[workerKey].scriptUrl = workerScriptUrl

    @startWebWorker: (workerKey) ->

      if not window.Worker
        logger.info('Web Workers API is not supported')
        return

      if not WORKERS[workerKey]
        return

      kWorker = WORKERS[workerKey]
      kWorker.start()

    @terminateWebWorker: (workerKey) ->

      if not window.Worker
        logger.info('Web Workers API is not supported')
        return

      if not WORKERS[workerKey]
        return

      kWorker = WORKERS[workerKey]
      kWorker.terminate()

    @queryWebWorker: (workerKey) ->

      if not window.Worker
        logger.info('Web Workers API is not supported')
        return

      if not WORKERS[workerKey]
        return

      kWorker = WORKERS[workerKey]
      return kWorker.query()

  return KryptnosticWorkersApi
