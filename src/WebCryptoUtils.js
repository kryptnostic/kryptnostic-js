/* eslint-disable no-console */

/*
 * @flow
 */

import Promise from 'bluebird';
import { forge } from 'forge';

const ENV_IS_WEB_WORKER =
  (typeof WorkerGlobalScope !== 'undefined')
  && (typeof window !== 'object')
  && (typeof self === 'object')
  && (typeof importScripts === 'function');

let isIE = false;
let webCryptoApi = null;

if (ENV_IS_WEB_WORKER) {
  // don't inline with the above if-statement
  if (self.crypto || self.msCrypto) {
    webCryptoApi = self.crypto || self.msCrypto;
  }
  if (self.msCrypto) {
    isIE = true;
  }
}
else {
  webCryptoApi = window.crypto || window.msCrypto;
}

if (webCryptoApi && webCryptoApi.webkitSubtle) {
  webCryptoApi.subtle = webCryptoApi.webkitSubtle;
}


function generateRSAKeyPairIE() {

  return new Promise((resolve, reject) => {

    const ieKeyOperation = webCryptoApi.subtle.generateKey(
      {
        name: 'RSA-OAEP',
        modulusLength: 4096, // can be 1024, 2048, or 4096
        publicExponent: new Uint8Array([0x01, 0x00, 0x01]),
        hash: {
          name: 'SHA-256' // can be SHA-1, SHA-256, SHA-384, or SHA-512
        }
      },
      true, // whether the key is extractable, i.e., whether it can be used in exportKey
      ['encrypt', 'decrypt']
    );

    ieKeyOperation.onerror = () => {
      postMessage('IE: generateKey() failed');
      reject('IE: generateKey() failed - reject()');
    };

    ieKeyOperation.oncomplete = () => {
      resolve(ieKeyOperation.result);
    };
  })
  .then((generateKeyPair) => {

    const publicKeyPromise = new Promise((resolve, reject) => {
      const ieKeyOperationPublicKey = webCryptoApi.subtle.exportKey('spki', generateKeyPair.publicKey);
      ieKeyOperationPublicKey.oncomplete = () => {
        resolve(ieKeyOperationPublicKey.result);
      };
      ieKeyOperationPublicKey.onerror = () => {
        postMessage('IE: exportKey() publicKey failed');
        reject('IE: exportKey() publicKey failed - reject()');
      };
    });

    const privateKeyPromise = new Promise((resolve, reject) => {
      const ieKeyOperationPrivateKey = webCryptoApi.subtle.exportKey('pkcs8', generateKeyPair.privateKey);
      ieKeyOperationPrivateKey.oncomplete = () => {
        resolve(ieKeyOperationPrivateKey.result);
      };
      ieKeyOperationPrivateKey.onerror = () => {
        postMessage('IE: exportKey() privateKey failed');
        reject('IE: exportKey() privateKey failed - reject()');
      };
    });

    return Promise.join(publicKeyPromise, privateKeyPromise, (publicKey, privateKey) =>
      ({
        publicKey,
        privateKey
      })
    );
  })
  .catch((e) => {
    postMessage(e);
  });

}


export function getRandomInt() {

  if (!webCryptoApi) {
    return null;
  }

  return webCryptoApi.getRandomValues(new Uint32Array(1))[0];
}

export function generateRSAKeyPair() {

  if (!webCryptoApi) {
    return Promise.reject('no Web Crypto API');
  }

  if (isIE) {
    return generateRSAKeyPairIE();
  }

  return webCryptoApi.subtle.generateKey(
    {
      name: 'RSA-OAEP',
      modulusLength: 4096, // can be 1024, 2048, or 4096
      publicExponent: new Uint8Array([0x01, 0x00, 0x01]),
      hash: {
        name: 'SHA-256' // can be SHA-1, SHA-256, SHA-384, or SHA-512
      }
    },
    true, // whether the key is extractable, i.e., whether it can be used in exportKey
    ['encrypt', 'decrypt']
  )
  .then((keyPair) => {

    const publicKeyPromise = webCryptoApi.subtle.exportKey('spki', keyPair.publicKey)
      .then((exportedPublicKeyArrayBuffer) => {
        const publicKeyAsUint8 = new Uint8Array(exportedPublicKeyArrayBuffer);
        return publicKeyAsUint8;
      })
      .catch((e) => {
        console.error(e);
      });
    const privateKeyPromise = webCryptoApi.subtle.exportKey('pkcs8', keyPair.privateKey)
      .then((exportedPrivateKeyArrayBuffer) => {
        const privateKeyAsUint8 = new Uint8Array(exportedPrivateKeyArrayBuffer);
        return privateKeyAsUint8;
      })
      .catch((e) => {
        console.error(e);
      });

    return Promise.all([
      Promise.resolve(keyPair),
      publicKeyPromise,
      privateKeyPromise
    ]);
  })
  .then((result) =>
    ({
      rsaKeyPair: result[0],
      publicKey: result[1],
      privateKey: result[2]
    })
  )
  .catch((e) => {
    // postMessage(e);
    console.error(e);
  });
}

export function generateRSAKeyPairForge() {

  console.time('forge.js - generate RSA key pair');
  const forgeKeys = forge.rsa.generateKeyPair(4096, new Uint8Array([0x01, 0x00, 0x01]));
  const privateKeyAsn1 = forge.pki.privateKeyToAsn1(forgeKeys.privateKey);
  const publicKeyAsn1 = forge.pki.publicKeyToAsn1(forgeKeys.publicKey);
  const keypair = {};
  keypair.privateKey = forge.asn1.toDer(privateKeyAsn1);
  keypair.publicKey = forge.asn1.toDer(publicKeyAsn1);
  console.timeEnd('forge.js - generate RSA key pair');
  return keypair;
}


export function rsaEncrypt(rsaKeyPair, dataAsUint8) {

  return webCryptoApi.subtle.encrypt(
    {
      name: 'RSA-OAEP'
    },
    rsaKeyPair.publicKey,
    dataAsUint8.buffer
  )
  .then((encryptedDataAsArrayBuffer) => {

    const encryptedDataAsUint8 = new Uint8Array(encryptedDataAsArrayBuffer);
    return encryptedDataAsUint8;
  })
  .catch((e) => {
    console.error(e);
  });
}

export function rsaDecrypt(rsaKeyPair, dataAsUint8) {

  return webCryptoApi.subtle.decrypt(
    {
      name: 'RSA-OAEP'
    },
    rsaKeyPair.privateKey,
    dataAsUint8.buffer
  )
  .then((decryptedDataAsArrayBuffer) => {

    const decryptedDataAsUint8 = new Uint8Array(decryptedDataAsArrayBuffer);
    return decryptedDataAsUint8;
  })
  .catch((e) => {
    console.error(e);
  });
}


export function aesGenerateKeyIE() {

  if (!webCryptoApi) {
    return null;
  }

  return new Promise((resolve, reject) => {

    const ieKeyOperation = webCryptoApi.subtle.generateKey(
      {
        name: 'AES-GCM',
        length: 256
      },
      true,
      ['encrypt', 'decrypt']
    );

    ieKeyOperation.onerror = () => {
      // postMessage('IE: AES generateKey() failed');
      reject('IE: AES-GCM generateKey() failed - reject()');
    };

    ieKeyOperation.oncomplete = () => {
      resolve(ieKeyOperation.result);
    };
  })
  .catch(
    () => {}
  );
}

export function aesEncryptIE(key, plaintextAsUint8) {

  if (!webCryptoApi) {
    return null;
  }

  console.log(key);
  console.log(plaintextAsUint8);

  const randomIV = webCryptoApi.getRandomValues(new Uint8Array(12));

  return new Promise((resolve, reject) => {

    const ieCryptoOperation = webCryptoApi.subtle.encrypt(
      {
        name: 'AES-GCM',
        iv: randomIV,
        tagLength: 128
      },
      key,
      plaintextAsUint8
    );

    ieCryptoOperation.onerror = (e) => {
      console.log('wtf IE?!');
      console.error(e);
      reject(new Error('IE: AES-GCM encrypt() failed - reject()'));
    };

    ieCryptoOperation.oncomplete = () => {
      console.log('IE AES-GCM encryption success!');
      console.log(ieCryptoOperation);
      console.log(ieCryptoOperation.result);
      resolve({
        iv: randomIV,
        data: ieCryptoOperation.result
      });
    };
  })
  .catch(
    () => {}
  );
}

export function aesDecryptIE(key, ciphertext) {

  if (!webCryptoApi) {
    return null;
  }

  console.log('IE AES-GCM decryption...');
  console.log(key);
  console.log(ciphertext);

  return new Promise((resolve, reject) => {

    const ieCryptoOperation = webCryptoApi.subtle.decrypt(
      {
        name: 'AES-GCM',
        length: 256,
        iv: ciphertext.iv,
        tag: ciphertext.data.tag,
        tagLength: 128
      },
      key,
      ciphertext.data.ciphertext
    );

    ieCryptoOperation.onerror = (e) => {
      console.log('wtf IE?!');
      console.error(e);
      reject(new Error('IE: AES-GCM decrypt() failed - reject()'));
    };

    ieCryptoOperation.oncomplete = () => {
      console.log('IE AES-GCM decryption success!');
      const decryptedDataAsUint8 = new Uint8Array(ieCryptoOperation.result);
      resolve(decryptedDataAsUint8);
    };
  })
  .catch(
    () => {}
  );
}


export function aesctrGenerateKeyIE() {

  if (!webCryptoApi) {
    return null;
  }

  return new Promise((resolve, reject) => {

    const ieKeyOperation = webCryptoApi.subtle.generateKey(
      {
        name: 'AES-CTR',
        length: 128
      },
      true,
      ['encrypt', 'decrypt']
    );

    ieKeyOperation.onerror = () => {
      console.error('WTF EDGE?!');
      reject('IE: AES-CTR generateKey() failed - reject()');
    };

    ieKeyOperation.oncomplete = () => {
      console.log(ieKeyOperation);
      resolve(ieKeyOperation.result);
    };
  })
  .catch(
    (e) => {console.error(e);}
  );
}

export function aesctrEncryptIE(key, plaintextAsUint8) {

  if (!webCryptoApi) {
    return null;
  }

  console.log(key);
  console.log(plaintextAsUint8);

  const randomCounter = webCryptoApi.getRandomValues(new Uint8Array(16));

  return new Promise((resolve, reject) => {

    const ieCryptoOperation = webCryptoApi.subtle.encrypt(
      {
        name: 'AES-CTR',
        length: 128,
        counter: randomCounter
      },
      key,
      plaintextAsUint8
    );

    ieCryptoOperation.onerror = (e) => {
      console.log('wtf IE?!');
      console.error(e);
      reject(new Error('IE: AES-CTR encrypt() failed - reject()'));
    };

    ieCryptoOperation.oncomplete = () => {
      console.log('IE AES-CTR encryption success!');
      console.log(ieCryptoOperation);
      console.log(ieCryptoOperation.result);
      resolve({
        counter: randomCounter,
        data: ieCryptoOperation.result
      });
    };
  })
  .catch(
    () => {}
  );
}

export function aesctrDecryptIE(key, ciphertext) {

  if (!webCryptoApi) {
    return null;
  }

  console.log('IE AES-CTR decryption...');
  console.log(key);
  console.log(ciphertext);

  return new Promise((resolve, reject) => {

    const ieCryptoOperation = webCryptoApi.subtle.decrypt(
      {
        name: 'AES-CTR',
        length: 128,
        counter: ciphertext.counter
      },
      key,
      ciphertext.data.ciphertext
    );

    ieCryptoOperation.onerror = (e) => {
      console.log('wtf IE?!');
      console.error(e);
      reject(new Error('IE: AES-CTR decrypt() failed - reject()'));
    };

    ieCryptoOperation.oncomplete = () => {
      console.log('IE AES-CTR decryption success!');
      const decryptedDataAsUint8 = new Uint8Array(ieCryptoOperation.result);
      resolve(decryptedDataAsUint8);
    };
  })
  .catch(
    () => {}
  );
}

export function sha256(dataAsUint8) {

  if (!webCryptoApi) {
    return null;
  }

  return new Promise((resolve, reject) => {

    const ieCryptoOperation = webCryptoApi.subtle.digest(
      {
        name: 'SHA-256'
      },
      dataAsUint8.buffer
    );

    ieCryptoOperation.onerror = (e) => {
      console.log('wtf IE?!');
      console.error(e);
      reject(new Error('IE: SHA-256 digest() failed - reject()'));
    };

    ieCryptoOperation.oncomplete = () => {
      console.log('IE: SHA-256 digest() success!');
      const decryptedDataAsUint8 = new Uint8Array(ieCryptoOperation.result);
      resolve(decryptedDataAsUint8);
    };

  });
}

export function hmac(dataAsUint8) {

  return new Promise((resolve, reject) => {


    const ieKeyOperation = webCryptoApi.subtle.generateKey(
      {
        name: 'HMAC',
        length: 256,
        hash: {
          name: 'SHA-256'
        }
      },
      true,
      ['sign', 'verify']
    );

    ieKeyOperation.onerror = () => {
      console.error('WTF EDGE?!');
      reject('IE: HMAC_SHA_256 generateKey() failed - reject()');
    };

    ieKeyOperation.oncomplete = () => {
      console.log('ieKeyOperation', ieKeyOperation);

      const cryptoKey = ieKeyOperation.result;
      console.log('cryptoKey.algorithm', cryptoKey.algorithm);
      const ieCryptoOperation = webCryptoApi.subtle.sign(
        {
          name: 'HMAC',
          length: 256,
          hash: {
            name: 'SHA-256'
          }
        },
        cryptoKey,
        dataAsUint8.buffer
      );

      ieCryptoOperation.onerror = (e) => {
        console.log('wtf IE?!');
        console.error(e);
        reject(new Error('IE: HMAC_SHA_256 sign() failed - reject()'));
      };

      ieCryptoOperation.oncomplete = () => {
        console.log('IE: HMAC_SHA_256 sign() success!');
        console.log('ieCryptoOperation.result', ieCryptoOperation.result);
        const decryptedDataAsUint8 = new Uint8Array(ieCryptoOperation.result);
        resolve(decryptedDataAsUint8);
      };
    };
  });
}

export function pbkdf2_sha1(data) {

  return new Promise((resolve, reject) => {

    const ieKeyOperation = webCryptoApi.subtle.importKey(
      'raw',
      data,
      {
        name: 'PBKDF2'
      },
      false,
      ['deriveKey']
    );

    ieKeyOperation.onerror = () => {
      console.error('WTF EDGE?!');
      reject('IE: PBKDF2_SHA_1 importKey() failed - reject()');
    };

    ieKeyOperation.oncomplete = () => {
      console.log('ieKeyOperation', ieKeyOperation);

      const cryptoKey = ieKeyOperation.result;
      console.log('cryptoKey.algorithm', cryptoKey.algorithm);
      resolve(cryptoKey);

      const randomSalt = webCryptoApi.getRandomValues(new Uint32Array(16));

      const ieCryptoOperation = webCryptoApi.subtle.deriveKey(
        { name: 'PBKDF2', salt: randomSalt, iterations: 128, hash: 'SHA-1' },
        cryptoKey,
        {
          name: 'AES-CTR',
          length: 128
        },
        true,
        ['encrypt', 'decrypt']
      );

      ieCryptoOperation.onerror = (e) => {
        console.log('wtf IE?!');
        console.error(e);
        reject(new Error('IE: PBKDF2_SHA_1 sign() failed - reject()'));
      };

      ieCryptoOperation.oncomplete = () => {
        console.log('IE: PBKDF2_SHA_1 deriveKey() success!');
        console.log('ieCryptoOperation.result', ieCryptoOperation.result);
        const decryptedDataAsUint8 = new Uint8Array(ieCryptoOperation.result);
        resolve(decryptedDataAsUint8);
      };
    };
  });
}
