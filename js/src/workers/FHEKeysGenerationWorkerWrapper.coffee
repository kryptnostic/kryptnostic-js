define 'kryptnostic.fhe-keys-gen-worker-wrapper', [
  'require',
  'bluebird',
  'kryptnostic.logger',
  'kryptnostic.worker-wrapper'
], (require) ->

  # libraries
  Promise = require 'bluebird'

  # kryptnostic
  WorkerWrapper = require 'kryptnostic.worker-wrapper'

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('FHEKeysGenerationWorkerWrapper')

  class FHEKeysGenerationWorkerWrapper extends WorkerWrapper

    constructor: ->
      super()

    query: ->

      if not @webWorker
        return Promise.reject()

      return new Promise (resolve, reject) =>

        # handle query response
        @webWorker.onmessage = (messageEvent) =>

          fheKeys = null
          if messageEvent and messageEvent.data
            fheKeys = messageEvent.data

          if fheKeys?
            resolve(fheKeys)
          else
            reject()

          @terminate()

        # execute query
        super({
          operation: 'getKeys'
        })

  return FHEKeysGenerationWorkerWrapper
