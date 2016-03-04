importScripts('forge.min.js', 'bluebird.min.js');

var RSA_KEY_SIZE = 4096;
var EXPONENT_NUM = 0x10001;
var EXPONENT_BIG_INT = new Uint8Array([1, 0, 1]);

var rsaKeyPair = {
  publicKey: null,
  privateKey: null
};

/*
 * we can't wrap the public key and private key in a forge buffer since the prototype chain will not be cloned when
 * passing the data along in postMessage()
 */
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

  if (self.crypto && self.crypto.subtle) {
    webCryptoGenerate();
  }
};

function getKeys() {

  if (rsaKeyPair === null || rsaKeyPair.publicKey === null || rsaKeyPair.privateKey === null) {
    postMessage(null);
  }
  postMessage(rsaKeyPair);
};

function webCryptoGenerate() {

  Promise.resolve()
    .then(function() {
      return self.crypto.subtle.generateKey(
        {
          name: 'RSA-OAEP',
          modulusLength: RSA_KEY_SIZE,
          publicExponent: EXPONENT_BIG_INT,
          hash: { name: 'SHA-256' }
        },
        true,
        ['encrypt', 'decrypt']
      );
    })
    .then(function(keys) {

      p1 = self.crypto.subtle.exportKey('pkcs8', keys.privateKey)
        .then(function(exportedPrivateKeyArrayBuffer) {
          return exportedPrivateKeyArrayBuffer;
        });

      p2 = self.crypto.subtle.exportKey('spki', keys.publicKey)
        .then(function(exportedPublicKeyArrayBuffer) {
          return exportedPublicKeyArrayBuffer;
        });

      Promise.join(p1, p2, function(privateKeyArrayBuffer, publicKeyArrayBuffer) {

        rsaKeyPair.publicKey = publicKeyArrayBuffer;
        rsaKeyPair.privateKey = privateKeyArrayBuffer;
        return;
      });
    })
    .catch(function(e) {
      rsaKeyPair = null;
    });
};
