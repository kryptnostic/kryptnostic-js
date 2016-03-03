var window = self;

importScripts('almond.js');
importScripts('KryptnosticClient.js', 'kryptnostic.js');

// libraries
var Cache = require('jscache');

// kryptnostic
var ConfigService = require('kryptnostic.configuration');
var CredentialProviderLoader = require('kryptnostic.credential-provider-loader');
var KryptnosticEngineProvider = require('kryptnostic.kryptnostic-engine-provider');
var LocalStorageCredentialProvider = require('kryptnostic.credential-provider.local-storage');
var ObjectIndexingService = require('kryptnostic.indexing.object-indexing-service');

// utils
var KeypairSerializer = require('kryptnostic.keypair-serializer');

/*
 * Web Workers do not have access to window.localStorage, so we define our own
 */
window.localStorage = new Cache()
LocalStorageCredentialProvider.delegate = window.localStorage;

var objectIndexingService = new ObjectIndexingService();

onmessage = function(options) {

  workerQuery = options.data;

  if (workerQuery) {
    if (workerQuery.operation === 'init') {
      init(workerQuery.params);
    } else if (workerQuery.operation === 'index') {
      index(workerQuery.params);
    }
  }
};

function init(queryParams) {

  // Web Workers need to inherit KJS config
  ConfigService.set(queryParams.config)

  /*
   * TODO:
   * we have to serialize the RSA key pair before passing it to the Web Worker, but we have to deserialize before
   * passing it to CredentialProvider.store(), which then serializes it again. we need to skip the deserialize step,
   * and be able to invoke CredentialProvider.store() with the serialized key pair
   */
  var rsaKeyPair = KeypairSerializer.hydrate(queryParams.rsaKeyPair)

  var credentialProvider = CredentialProviderLoader.load(ConfigService.get('credentialProvider'))
  credentialProvider.store({
    principal: queryParams.principal,
    credential: queryParams.credential,
    keypair: rsaKeyPair
  });

  KryptnosticEngineProvider.init({
    fhePrivateKey: queryParams.fhePrivateKey,
    fheSearchPrivateKey: queryParams.fheSearchPrivateKey
  });
};

function index(queryParams) {

  var data = queryParams.data;
  var objectKey = queryParams.objectKey;
  var parentObjectKey = queryParams.parentObjectKey;

  // ToDo - indexing queue
  objectIndexingService.index(data, objectKey, parentObjectKey);
};
