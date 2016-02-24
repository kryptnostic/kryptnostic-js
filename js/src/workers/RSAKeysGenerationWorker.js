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
  } else if (self.msCrypto && self.msCrypto.subtle) {
    ieWebCryptoGenerate();
  } else {
    forgeGenerate();
  }
};

function forgeGenerate() {

  Promise.resolve()
    .then(function() {

      forgeKeys       = forge.rsa.generatekeypair(RSA_KEY_SIZE, EXPONENT_NUM);
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

/*
function ieWebCryptoGenerate() {

  Promise.resolve()
    .then(function() {

      deferred = Promise.defer()
      keyOperation = self.msCrypto.subtle.generateKey(
        {
          name: 'RSA-OAEP',
          modulusLength: RSA_KEY_SIZE,
          publicExponent: EXPONENT_BIG_INT,
          hash: { name: 'SHA-256' }
        },
        true,
        ['encrypt', 'decrypt']
      );

      keyOperation.onerror = function() {
        // close worker?
        // log.error('Failed to generate RSA keys using IE web crypto');
      };

      keyOperation.oncomplete = function() {
        keypair = keyOperation.result;
        return deferred.resolve(keypair);
      };

      return deferred.promise;
    })
    .then(function(keys) {

      deferred1 = Promise.defer();
      keyOpPrivate = self.msCrypto.subtle.exportKey('pkcs8', keys.privateKey);
      keyOpPrivate.onerror = function() {
        // close worker?
        // log.error('Failed to export RSA private key using IE web crypto')
      };
      keyOpPrivate.oncomplete = function() {
        return deferred1.resolve(keyOpPrivate.result);
      };

      privateKeyPromise = deferred1.promise;

      deferred2 = Promise.defer();
      keyOpPublic = self.msCrypto.subtle.exportKey('spki', keys.publicKey);
      keyOpPublic.onerror = function() {
        // close worker?
        // log.error('Failed to export RSA public key using IE web crypto')
      };
      keyOpPublic.oncomplete = function() {
        return deferred2.resolve(keyOpPublic.result);
      };

      publicKeyPromise = deferred2.promise;

      return Promise.join(privateKeyPromise, publicKeyPromise, function(privateKey, publicKey) {
        rsaKeyPair.publicKey = publicKey;
        rsaKeyPair.privateKey = privateKey;
        return;
      });
    })
    .catch(function(e) {
      self.close();
    });
};
*/
