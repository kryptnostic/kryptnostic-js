/*
 * @flow
 */

declare class WorkerGlobalScope {}
declare function importScripts(...scripts :Array<string>) :void;

/*
 * SubtleCryptoAPI is wrapper around the browser's implementation of the Web Crypto API, specifically, window.crypto
 * and window.crypto.subtle. it consolidates window.crypto.getRandomValues() together with window.crypto.subtle.*
 * under a single API for simplicity. additionally, it takes into consideration whether or not the code is executing
 * on the main thread, or inside a Web Worker where "self" exists in place of "window".
 */
const SubtleCryptoAPI = {};

function consolidateSubtleCryptoAPI(crypto, subtle) {

  SubtleCryptoAPI.getRandomValues = (...args :any[]) => {
    return crypto.getRandomValues.apply(crypto, args);
  };

  SubtleCryptoAPI.encrypt = (...args :any[]) => {
    return subtle.encrypt.apply(subtle, args);
  };

  SubtleCryptoAPI.decrypt = (...args :any[]) => {
    return subtle.decrypt.apply(subtle, args);
  };

  SubtleCryptoAPI.digest = (...args :any[]) => {
    return subtle.digest.apply(subtle, args);
  };

  SubtleCryptoAPI.sign = (...args :any[]) => {
    return subtle.sign.apply(subtle, args);
  };

  SubtleCryptoAPI.verify = (...args :any[]) => {
    return subtle.verify.apply(subtle, args);
  };

  SubtleCryptoAPI.generateKey = (...args :any[]) => {
    return subtle.generateKey.apply(subtle, args);
  };

  SubtleCryptoAPI.importKey = (...args :any[]) => {
    return subtle.importKey.apply(subtle, args);
  };

  SubtleCryptoAPI.exportKey = (...args :any[]) => {
    return subtle.exportKey.apply(subtle, args);
  };

  SubtleCryptoAPI.deriveKey = (...args :any[]) => {
    return subtle.deriveKey.apply(subtle, args);
  };

  SubtleCryptoAPI.wrapKey = (...args :any[]) => {
    return subtle.wrapKey.apply(subtle, args);
  };

  SubtleCryptoAPI.unwrapKey = (...args :any[]) => {
    return subtle.unwrapKey.apply(subtle, args);
  };
}

/*
 * figure out if we're running inside a Web Worker
 */
const ENV_IS_WEB_WORKER =
  (typeof WorkerGlobalScope !== 'undefined')
  && (typeof window !== 'object')
  && (typeof self === 'object')
  && (typeof importScripts === 'function');

if (ENV_IS_WEB_WORKER) {
  if (self.crypto && self.crypto.subtle) {
    consolidateSubtleCryptoAPI(self.crypto, self.crypto.subtle);
  }
  else if (self.crypto && self.crypto.webkitSubtle) {
    consolidateSubtleCryptoAPI(self.crypto, self.crypto.webkitSubtle);
  }
  else if (self.msCrypto && self.msCrypto.subtle) {
    consolidateSubtleCryptoAPI(self.msCrypto, self.msCrypto.subtle);
  }
}
else {
  if (window.crypto && window.crypto.subtle) {
    consolidateSubtleCryptoAPI(window.crypto, window.crypto.subtle);
  }
  else if (window.crypto && window.crypto.webkitSubtle) {
    consolidateSubtleCryptoAPI(window.crypto, window.crypto.webkitSubtle);
  }
  else if (window.msCrypto && window.msCrypto.subtle) {
    consolidateSubtleCryptoAPI(window.msCrypto, window.msCrypto.subtle);
  }
}

SubtleCryptoAPI.isAvailable = () => {

  // the check is for greater than 1 because isAvailable() is already on the prototype
  return Object.keys(SubtleCryptoAPI).length > 1;
};

export default SubtleCryptoAPI;
