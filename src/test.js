/* eslint-disable no-console */

/*
 * @flow
 */
declare var __VERSION__;

import Promise from 'bluebird';
import { forge } from 'forge';
// import * as KryptoConstants from './KryptoConstants';
// import * as KryptoUtils from './KryptoUtils';

// import KryptoEngine from './KryptoEngine';
import MyWorker from 'worker!webcryptoWorker';
import * as WebCryptoUtils from './WebCryptoUtils';
import * as BinaryUtils from './utils/BinaryUtils';

import WebCryptoAPI from './webcrypto/WebCryptoAPI';

console.log('Hello World!');
console.log('================');
console.log(typeof forge);

// function strToUint8(str) {
//
//   const codes = [];
//   for (let i = 0; i < str.length; i++) {
//     const c = str.charAt(i);
//     const code = c.charCodeAt();
//     codes.push(code);
//   }
//   return new Uint8Array(codes);
// }
//
// function uint8ToStr(uint8) {
//
//   let str = '';
//   for (let i = 0; i < uint8.length; i++) {
//     str += String.fromCharCode(uint8[i]);
//   }
//   return str;
// }


BinaryUtils.stringToUint8('helloworld');

// WebCryptoAPI.AES_GCM_256
//   .generateCryptoKey()
//   .then((cryptoKey) => {
//     console.log(cryptoKey);
//     return WebCryptoAPI.AES_GCM_256
//       .encrypt(cryptoKey, strToUint8('WebCryptoAPI!!!'))
//       .then((ciphertext) => {
//         console.log(ciphertext);
//         WebCryptoAPI.AES_GCM_256
//           .decrypt(cryptoKey, ciphertext)
//           .then((plaintext) => {
//             console.log('decrypted:');
//             console.log(uint8ToStr(plaintext));
//           });
//       });
//   });

// WebCryptoAPI.AES_CTR_128
//   .generateCryptoKey()
//   .then((cryptoKey) => {
//     console.log(cryptoKey);
//     if (!cryptoKey) {
//       throw new Error('wtf happened to key generation?');
//     }
//     return WebCryptoAPI.AES_CTR_128
//       .encrypt(cryptoKey, strToUint8('WebCryptoAPI!!!'))
//       .then((ciphertext) => {
//         console.log(ciphertext);
//         WebCryptoAPI.AES_CTR_128
//           .decrypt(cryptoKey, ciphertext)
//           .then((plaintext) => {
//             console.log('decrypted:');
//             console.log(uint8ToStr(plaintext));
//           });
//       });
//   });

// WebCryptoAPI.SHA_256
//   .digest(strToUint8('WebCryptoAPI!!!'))
//   .then((hash) => {
//     console.log(hash);
//     console.log(uint8ToStr(hash));
//   });

// function computeHMAC(aesCryptoKey) {
//
//   return WebCryptoAPI.AES_CTR_128
//     .exportCryptoKey(aesCryptoKey)
//     .then((aesCryptoKeyAsUint8) => {
//
//       console.log('exported key:');
//       console.log(aesCryptoKeyAsUint8);
//
//       return WebCryptoAPI.HMAC_SHA_256
//         .importCryptoKey(aesCryptoKeyAsUint8)
//         .then((key) => {
//
//           console.log('imported key:');
//           console.log(key);
//
//           return WebCryptoAPI.HMAC_SHA_256
//             .sign(key, strToUint8('WebCryptoAPI!!!'))
//             .then((signature) => {
//               console.log('signature:');
//               console.log(signature);
//             });
//         });
//     });
// }

// WebCryptoAPI.HMAC_SHA_256
//   .generateCryptoKey()
//   .then((cryptoKey) => {
//     console.log(cryptoKey);
//     return WebCryptoAPI.HMAC_SHA_256
//       .sign(cryptoKey, strToUint8('WebCryptoAPI!!!'))
//       .then((signature) => {
//         console.log('signature:');
//         console.log(signature);
//       });
//   });

// WebCryptoAPI.PBKDF2_SHA_1
//   .importCryptoKey(strToUint8('WebCryptoAPI!!!'))
//   .then((cryptoKey) => {
//     console.log(cryptoKey);
//     WebCryptoAPI.PBKDF2_SHA_1
//       .deriveCryptoKey(cryptoKey, WebCryptoAPI.AES_CTR_128.ALGORITHM_DESCRIPTION)
//       .then((derivedCryptoKey) => {
//         console.log(derivedCryptoKey);
//       });
//   });

// const worker = new MyWorker();
// worker.postMessage({
//   username: 'hristo',
//   password: 'password'
// });
// worker.onmessage = function onmessage(messageEvent) {
//   console.log(messageEvent);
// };

// console.log('generateRSAKeyPair() in main thread...');
// console.time('WebCrypto RSA key generation');
// Promise.resolve(
//   WebCryptoUtils.generateRSAKeyPair()
// ).then((result) => {
//   console.timeEnd('WebCrypto RSA key generation');
//   console.log(result);
//   console.log(result.publicKey.byteLength);
//   console.log(result.privateKey.byteLength);
//
//
//   console.time('WebCrypto RSA encryption');
//   console.log('trying to encrypt data:', 'WebCrypto!!!');
//   return Promise.resolve(
//     WebCryptoUtils.rsaEncrypt(result.rsaKeyPair, strToUint8('WebCrypto!!!'))
//   ).then((encryptedDataAsUint8) => {
//     console.timeEnd('WebCrypto RSA encryption');
//     console.time('WebCrypto RSA decrypt');
//     return Promise.resolve(
//       WebCryptoUtils.rsaDecrypt(result.rsaKeyPair, encryptedDataAsUint8)
//     ).then((decryptedDataAsUint8) => {
//       console.timeEnd('WebCrypto RSA decrypt');
//       const data = uint8ToStr(decryptedDataAsUint8);
//       console.log('decrypted data:', data);
//     }).catch((e) => {
//       console.error(e);
//     })
//   }).catch((e) => {
//     console.error(e);
//   })
// }).catch((e) => {
//   console.error(e);
// });


// console.log('AES-GCM - generateKey()');
// console.time('AES-GCM - generateKey()');
// Promise.resolve(
//   WebCryptoUtils.generateKeyAESGCM()
// )
// .then((aesKey) => {
//
//   console.timeEnd('AES-GCM - generateKey()');
//
//   const plaintext = 'Web Crypto API!!!';
//   console.log('encrypting data...', plaintext);
//
//   console.time('AES-GCM - encrypt()');
//   return Promise.resolve(
//     WebCryptoUtils.encryptAESGCM(aesKey, strToUint8(plaintext))
//   )
//   .then((ciphertextStuff) => {
//
//     console.timeEnd('AES-GCM - encrypt()');
//
//     console.log(ciphertextStuff);
//
//     console.time('AES-GCM - decrypt()');
//     return Promise.resolve(
//       WebCryptoUtils.decryptAESGCM(aesKey, ciphertextStuff)
//     )
//     .then((plaintextAsUint8) => {
//
//       console.timeEnd('AES-GCM - decrypt()');
//       console.log('decrypted data...', uint8ToStr(plaintextAsUint8));
//     })
//     .catch((e) => {
//       console.error(e);
//     });
//   })
//   .catch((e) => {
//     console.error(e);
//   });
// })
// .catch((e) => {
//   console.error(e);
// });


// Promise.resolve(
//   WebCryptoUtils.aesGenerateKeyIE()
// )
// .then((aeskey) => {
//
//   console.log(aeskey);
//   Promise.resolve(
//     WebCryptoUtils.aesEncryptIE(aeskey, strToUint8('WebCryptoAPI!!!'))
//   )
//   .then((encrypted) => {
//
//     console.log(encrypted);
//
//     Promise.resolve(
//       WebCryptoUtils.aesDecryptIE(aeskey, encrypted)
//     )
//     .then((decrypted) => {
//
//       console.log(decrypted);
//       console.log(uint8ToStr(decrypted));
//     })
//     .catch((e) => {
//       console.error(e);
//     });
//   })
//   .catch((e) => {
//     console.error(e);
//   });
// })
// .catch((e) => {
//   console.error(e);
// });


// console.log('IE: AES-CTR');
// Promise.resolve(
//   WebCryptoUtils.aesctrGenerateKeyIE()
// )
// .then((aeskey) => {
//
//   console.log(aeskey);
//   Promise.resolve(
//     WebCryptoUtils.aesctrEncryptIE(aeskey, strToUint8('WebCryptoAPI!!!'))
//   )
//   .then((encrypted) => {
//
//     console.log(encrypted);
//
//     Promise.resolve(
//       WebCryptoUtils.aesctrDecryptIE(aeskey, encrypted)
//     )
//     .then((decrypted) => {
//
//       console.log(decrypted);
//       console.log(uint8ToStr(decrypted));
//     })
//     .catch((e) => {
//       console.error(e);
//     });
//   })
//   .catch((e) => {
//     console.error(e);
//   });
// })
// .catch((e) => {
//   console.error(e);
// });

// console.log('IE: SHA-256');
// Promise.resolve(
//   WebCryptoUtils.sha256(strToUint8('WebCryptoAPI!!!'))
// )
// .then((hash) => {
//   console.log(hash);
//   console.log(uint8ToStr(hash));
// });

// console.log('IE: HMAC_SHA_256');
// Promise.resolve(
//   WebCryptoUtils.hmac(strToUint8('WebCryptoAPI!!!'))
// )
// .then((signature) => {
//   console.log('signature:', signature);
//   console.log(signature);
//   console.log('signature uint8:', uint8ToStr(signature));
// });

// console.log('IE: PBKDF2_SHA_1');
// Promise.resolve(
//   WebCryptoUtils.pbkdf2_sha1(strToUint8('WebCryptoAPI!!!'))
// )
// .then(() => {
//   console.log('key derivation complete');
// });


//
// console.log('forge.js - generate RSA key pair in main thread...');
// const keypair = generateRSAKeyPairForge();
// console.log(keypair);
// console.log(keypair.publicKey.byteLength);
// console.log(keypair.privateKey.byteLength);


// console.log('KryptoEngine.init()');
// KryptoEngine.init();
// const engine = KryptoEngine.getEngine();
// engine.getFHEPrivateKey();
// engine.getFHESearchPrivateKey();


module.exports = {
  __VERSION__
};
