importScripts('KryptnosticClient.js');

var fheKeys = {
  FHE_PRIVATE_KEY: null,
  FHE_SEARCH_PRIVATE_KEY: null,
  FHE_HASH_FUNCTION: null
};

onmessage = function(options) {

  workerQuery = options.data;

  if (workerQuery) {
    if (workerQuery.operation === 'init') {
      generateKeys();
    } else if (workerQuery.operation === 'getKeys') {
      getKeys();
    }
  }
};

function generateKeys() {

  krypto = new Module.KryptnosticClient();

  fhePrivateKey = new Uint8Array(krypto.getPrivateKey());
  fheSearchPrivateKey = new Uint8Array(krypto.getSearchPrivateKey());
  fheHashFunction = new Uint8Array(krypto.calculateClientHashFunction());

  fheKeys.FHE_PRIVATE_KEY = fhePrivateKey;
  fheKeys.FHE_SEARCH_PRIVATE_KEY = fheSearchPrivateKey;
  fheKeys.FHE_HASH_FUNCTION = fheHashFunction;
};

function getKeys() {

  if (fheKeys === null ||
      fheKeys.FHE_PRIVATE_KEY === null ||
      fheKeys.FHE_SEARCH_PRIVATE_KEY === null ||
      fheKeys.FHE_HASH_FUNCTION === null) {
    postMessage(null);
  }
  postMessage(fheKeys);
};
