define 'kryptnostic.rsa-keys-gen-worker-wrapper', [
  'require',
  'forge',
  'kryptnostic.logger',
  'kryptnostic.worker-wrapper'
], (require) ->

  # libraries
  forge = require 'forge'

  # kryptnostic
  WorkerWrapper = require 'kryptnostic.worker-wrapper'

  # utils
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('RSAKeysGenerationWorkerWrapper')

  class RSAKeysGenerationWorkerWrapper extends WorkerWrapper

    constructor: ->
      super()

    query: ->

      if not @webWorker
        return Promise.reject()

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
            reject()

        # execute query
        super({
          operation: 'getKeys'
        })

  return RSAKeysGenerationWorkerWrapper
