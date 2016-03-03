define 'kryptnostic.object-indexing-worker-wrapper', [
  'require',
  'kryptnostic.configuration',
  'kryptnostic.credential-loader',
  'kryptnostic.keypair-serializer',
  'kryptnostic.kryptnostic-engine-provider',
  'kryptnostic.logger',
  'kryptnostic.worker-wrapper'
], (require) ->

  # kryptnostic
  ConfigService = require 'kryptnostic.configuration'
  CredentialLoader = require 'kryptnostic.credential-loader'
  KryptnosticEngineProvider = require 'kryptnostic.kryptnostic-engine-provider'
  WorkerWrapper = require 'kryptnostic.worker-wrapper'

  # utils
  KeypairSerializer = require 'kryptnostic.keypair-serializer'
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('FHEKeysGenerationWorkerWrapper')

  class ObjectIndexingWorkerWrapper extends WorkerWrapper

    constructor: ->
      super()

    start: ->

      workerParams = {}
      workerParams.config = ConfigService.config

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

      if not @webWorker
        # TODO - reject with an Error instance
        return Promise.reject()

      # execute query
      super(workerQuery)

  return ObjectIndexingWorkerWrapper
