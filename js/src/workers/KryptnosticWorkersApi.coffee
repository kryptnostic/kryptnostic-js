# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.kryptnostic-workers-api', [
  'require',
  'forge',
  'kryptnostic.credential-loader',
  'kryptnostic.keypair-serializer',
  'kryptnostic.kryptnostic-engine-provider',
  'kryptnostic.logger'
], (require) ->

  # libraries
  forge = require 'forge'

  # kryptnostic
  CredentialLoader = require 'kryptnostic.credential-loader'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'

  # utils
  KeypairSerializer = require 'kryptnostic.keypair-serializer'
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('KryptnosticWorkersApi')

  #
  # internal classes
  #

  class KryptnosticWorker

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
        return Promise.resolve()

      @webWorker.postMessage(workerQuery)

  class FHEKeysGenerationWorker extends KryptnosticWorker

    constructor: ->
      super()

    query: ->

      if not @webWorker
        return Promise.resolve()

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
        super({
          operation: 'getKeys'
        })
        return

  class RSAKeysGenerationWorker extends KryptnosticWorker

    constructor: ->
      super()

    query: ->

      if not @webWorker
        return Promise.resolve()

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
        super({
          operation: 'getKeys'
        })
        return

  class ObjectIndexingWorker extends KryptnosticWorker

    constructor: ->
      super()

    start: ->

      workerParams = {}

      credentialLoader = new CredentialLoader()
      credentials = credentialLoader.getCredentials()
      workerParams.principal = credentials.principal
      workerParams.credential = credentials.credential

      # we have to serialize the RSA key pair before passing it to the Web Worker
      serializedKeyPair = KeypairSerializer.serialize(credentials.keypair)
      workerParams.rsaKeyPair = serializedKeyPair

      engine = KryptnosticEngineProvider.getEngine()
      workerParams.fhePrivateKey = engine.getPrivateKey()
      workerParams.fheSearchPrivateKey = engine.getSearchPrivateKey()

      super(workerParams)

    query: (workerQuery) ->

      throw new Error('ObjectIndexingWorker:query() - not yet implemented!')

      # if not @webWorker
      #   return Promise.resolve()
      #
      # return new Promise (resolve, reject) =>
      #
      #   @webWorker.onmessage = (messageEvent) ->
      #     resolve()
      #
      #   # execute query
      #   super(workerQuery)
      #   return
  #
  # external API for interacting with web workers
  #

  class KryptnosticWorkersApi

    @FHE_KEYS_GEN_WORKER = 'FHE_KEYS_GEN_WORKER'
    @RSA_KEYS_GEN_WORKER = 'RSA_KEYS_GEN_WORKER'
    @OBJ_INDEXING_WORKER = 'OBJ_INDEXING_WORKER'

    WORKERS = {
      FHE_KEYS_GEN_WORKER: new FHEKeysGenerationWorker()
      RSA_KEYS_GEN_WORKER: new RSAKeysGenerationWorker()
      OBJ_INDEXING_WORKER: new ObjectIndexingWorker()
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
        return

      if not WORKERS[workerKey]
        return

      kWorker = WORKERS[workerKey]
      return kWorker.query(workerQuery)

  return KryptnosticWorkersApi
