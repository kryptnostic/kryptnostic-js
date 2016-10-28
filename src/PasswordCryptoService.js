/*
 * @flow
 */

import WebCryptoAPI from './webcrypto/WebCryptoAPI';

function strToUint8(str) {

  const codes = [];
  for (let i = 0; i < str.length; i++) {
    const c = str.charAt(i);
    const code = c.charCodeAt();
    codes.push(code);
  }
  return new Uint8Array(codes);
}

export class PasswordCryptoService {

  constructor() {
    this.derivedCryptoKey = null;
  }

  encrypt(plaintext, password) {

    const plaintextAsUint8 = strToUint8(plaintext);
    const passwordAsUint8 = strToUint8(password);

    WebCryptoAPI.PBKDF2_SHA_1
      .importCryptoKey(passwordAsUint8)
      .then((importedCryptoKey) => {
        WebCryptoAPI.PBKDF2_SHA_1
          .deriveCryptoKey(importedCryptoKey, WebCryptoAPI.AES_CTR_128.ALGORITHM_DESCRIPTION)
          .then((passwordDerivedCryptoKey) => {
            this.derivedCryptoKey = passwordDerivedCryptoKey;
          });
      });
  }
}
