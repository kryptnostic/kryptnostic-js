var window = self;

importScripts('almond.js');
importScripts('KryptnosticClient.js', 'kryptnostic.js');

// libraries
var Cache = require('jscache');

// APIs
var ObjectApi = require('kryptnostic.object-api');
var SearchApi = require('kryptnostic.search-api');
var SharingApi = require('kryptnostic.sharing-api');

// kryptnostic
var Config = require('kryptnostic.configuration');
var CredentialProviderLoader = require('kryptnostic.credential-provider-loader');
var CryptoServiceLoader = require('kryptnostic.crypto-service-loader');
var KryptnosticEngineProvider = require('kryptnostic.kryptnostic-engine-provider');
var LocalStorageCredentialProvider = require('kryptnostic.credential-provider.local-storage');
var ObjectIndexingService = require('kryptnostic.indexing.object-indexing-service');

// utils
var BinaryUtils = require('kryptnostic.binary-utils');
var HashFunction = require('kryptnostic.hash-function');
var KeypairSerializer = require('kryptnostic.keypair-serializer');
var Validators = require('kryptnostic.validators');

// constants
// defined in com.kryptnostic.v2.storage.types.TypeUUIDs
var INDEX_SEGMENT_TYPE_ID = '00000000-0000-0000-0000-000000000007';

/*
 * Web Workers do not have access to window.localStorage, so we define our own
 */
window.localStorage = new Cache()
LocalStorageCredentialProvider.delegate = window.localStorage;

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

  /*
   * TODO:
   * we have to serialize the RSA key pair before passing it to the Web Worker, but we have to deserialize before
   * passing it to CredentialProvider.store(), which then serializes it again. we need to skip the deserialize step,
   * and be able to invoke CredentialProvider.store() with the serialized key pair
   */
  var rsaKeyPair = KeypairSerializer.hydrate(queryParams.rsaKeyPair)

  var credentialProvider = CredentialProviderLoader.load(Config.get('credentialProvider'))
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

};
