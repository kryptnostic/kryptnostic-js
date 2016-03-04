# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.kryptnostic-workers-api', [
  'require',
  'bluebird',
  'kryptnostic.fhe-keys-gen-worker-wrapper',
  'kryptnostic.rsa-keys-gen-worker-wrapper',
  'kryptnostic.object-indexing-worker-wrapper',
  'kryptnostic.logger'
], (require) ->

  # libraries
  Promise = require 'bluebird'

  # kryptnostic
  FHEKeysGenerationWorkerWrapper = require 'kryptnostic.fhe-keys-gen-worker-wrapper'
  RSAKeysGenerationWorkerWrapper = require 'kryptnostic.rsa-keys-gen-worker-wrapper'
  ObjectIndexingWorkerWrapper = require 'kryptnostic.object-indexing-worker-wrapper'

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('KryptnosticWorkersApi')

  class KryptnosticWorkersApi

    @FHE_KEYS_GEN_WORKER = 'FHE_KEYS_GEN_WORKER'
    @RSA_KEYS_GEN_WORKER = 'RSA_KEYS_GEN_WORKER'
    @OBJ_INDEXING_WORKER = 'OBJ_INDEXING_WORKER'

    WORKERS = {
      FHE_KEYS_GEN_WORKER: new FHEKeysGenerationWorkerWrapper()
      RSA_KEYS_GEN_WORKER: new RSAKeysGenerationWorkerWrapper()
      OBJ_INDEXING_WORKER: new ObjectIndexingWorkerWrapper()
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

    @queryWebWorker: (workerKey, workerQuery) ->

      if not window.Worker
        logger.info('Web Workers API is not supported')
        return Promise.reject()

      if not WORKERS[workerKey]
        return Promise.reject()

      kWorker = WORKERS[workerKey]
      return kWorker.query(workerQuery)

  return KryptnosticWorkersApi
