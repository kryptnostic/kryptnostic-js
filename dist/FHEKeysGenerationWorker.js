importScripts('KryptnosticClient.js');

var fheKeys = {
  FHE_PRIVATE_KEY: null,
  FHE_SEARCH_PRIVATE_KEY: null,
  FHE_HASH_FUNCTION: null
};

onmessage = function(options) {

  if (options.data && options.data.query) {
    if (fheKeys.FHE_PRIVATE_KEY === null ||
        fheKeys.FHE_SEARCH_PRIVATE_KEY === null ||
        fheKeys.FHE_HASH_FUNCTION === null) {
      postMessage(null);
    }
    postMessage(fheKeys);
    self.close();
  } else {
    generateKeys();
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
