define 'kryptnostic.worker-wrapper', [
  'require',
  'kryptnostic.logger'
], (require) ->

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('WorkerWrapper')

  class WorkerWrapper

    constructor: ->
      @scriptUrl = null
      @webWorker = null

    start: (workerParams) ->

      if _.isEmpty(@scriptUrl)
        return

      if @webWorker?
        return

      @webWorker = new Worker(@scriptUrl)
      @webWorker.postMessage({
        operation: 'init',
        params: workerParams
      })

    terminate: ->

      if not @webWorker
        return

      @webWorker.terminate()
      @webWorker = null
      @scriptUrl = null

    query: (workerQuery) ->

      if not @webWorker or not workerQuery
        return Promise.reject()

      @webWorker.postMessage(workerQuery)

      return Promise.resolve()

  return WorkerWrapper
