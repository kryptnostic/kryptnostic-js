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

  if (options.data && options.data.query) {
    if (rsaKeyPair.publicKey === null || rsaKeyPair.privateKey === null) {
      postMessage(null);
    }
    postMessage(rsaKeyPair);
  } else {
    generateKeys();
  }
};

function generateKeys() {

  if (self.crypto && self.crypto.subtle) {
    webCryptoGenerate();
  } else {
    forgeGenerate();
  }
};

function forgeGenerate() {

  Promise.resolve()
    .then(function() {

      forgeKeys       = forge.rsa.generateKeyPair(RSA_KEY_SIZE, EXPONENT_NUM);
      privateKeyAsn1  = forge.pki.privateKeyToAsn1(forgeKeys.privateKey);
      publicKeyAsn1   = forge.pki.publicKeyToAsn1(forgeKeys.publicKey);
      privateKeyAsDer = forge.asn1.toDer(privateKeyAsn1);
      publicKeyAsDer  = forge.asn1.toDer(publicKeyAsn1);

      rsaKeyPair.publicKey = publicKeyAsDer.data;
      rsaKeyPair.privateKey = privateKeyAsDer.data;
      return;
    })
    .catch(function(e) {
      self.close();
    });
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
      // https://github.com/digitalbazaar/forge/issues/284#issuecomment-128388734
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
      self.close();
    });
};
