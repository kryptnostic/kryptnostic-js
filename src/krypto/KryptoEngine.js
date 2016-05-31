/*
 * @flow
 */

/*
 * importing and referencing KryptoJS is ugly, but the webpack exports-loader makes it much nicer. the loader lets us
 * export global variables from inside krypto.js into the webpack global context under a new interface, "Krypto".
 * now, we are able to get a Krypto instance in two easy ways:
 *
 *   1.
 *     import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';
 *     const krypto = new Krypto();
 *
 *   2.
 *     import KryptoJS from 'exports?Krypto=Module.KryptnosticClient!krypto-js';
 *     const krypto = new KryptoJS.Krypto();
 *
 * simple :)
 *
 * https://webpack.github.io/docs/shimming-modules.html#exporting
 * https://github.com/webpack/exports-loader
 */
import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';
import * as KryptoUtils from './KryptoUtils';

/*
 * the Krypto singleton instance, guarded by the KryptoEngine singleton instance
 */
let kryptoInstance :Krypto = null;

/*
 * the KryptoEngine singleton instance
 */
let kryptoEngineInstance = null;

/*
 * KryptoEngine is a singleton wrapper around KryptoJS, exposing core functionality and convenient helper methods
 */
class KryptoEngine {

  constructor(fhePrivateKey :?Uint8Array = null, fheSearchPrivateKey :?Uint8Array = null) {

    if (kryptoEngineInstance !== null) {
      throw new Error('KryptoEngine has already been initialized');
    }

    if (KryptoUtils.isValidFHEPrivateKey(fhePrivateKey)
        && KryptoUtils.isValidFHESearchPrivateKey(fheSearchPrivateKey)) {
      kryptoInstance = new Krypto(fhePrivateKey, fheSearchPrivateKey);
    }
    else {
      kryptoInstance = new Krypto();
    }
  }

  getFHEPrivateKey() :Uint8Array {

    return new Uint8Array(kryptoInstance.getPrivateKey());
  }

  getFHESearchPrivateKey() :Uint8Array {

    return new Uint8Array(kryptoInstance.getSearchPrivateKey());
  }

  getFHEHashFunction() :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateClientHashFunction());
  }

  generateObjectIndexPair() :Uint8Array {

    return new Uint8Array(kryptoInstance.generateObjectIndexPair());
  }

  generateObjectSearchPair() :Uint8Array {

    const objIndexPair = this.generateObjectIndexPair();
    const objSearchPair = this.calculateObjectSearchPairFromObjectIndexPair(objIndexPair);
    return objSearchPair;
  }

  calculateObjectIndexPairFromObjectSearchPair(objSearchPair :Uint8Array) :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateObjectIndexPairFromObjectSearchPair(objSearchPair));
  }

  calculateObjectSearchPairFromObjectIndexPair(objIndexPair :Uint8Array) :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateObjectSearchPairFromObjectIndexPair(objIndexPair));
  }

  calculateObjectSearchPairFromObjectSharePair(objSharePair :Uint8Array) :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateObjectSearchPairFromObjectSharePair(objSharePair));
  }

  calculateObjectSharePairFromObjectSearchPair(objSearchPair :Uint8Array) :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateObjectSharePairFromObjectSearchPair(objSearchPair));
  }

  calculateEncryptedSearchToken(token :Uint8Array) :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateEncryptedSearchToken(token));
  }

  calculateMetadataAddress(objIndexPair :Uint8Array, token :Uint8Array) :Uint8Array {

    return new Uint8Array(kryptoInstance.calculateMetadataAddress(objIndexPair, token));
  }
}

function init(fhePrivateKey :?Uint8Array = null, fheSearchPrivateKey :?Uint8Array = null) {

  if (kryptoEngineInstance !== null) {
    throw new Error('KryptoEngine has already been initialized');
  }

  kryptoEngineInstance = new KryptoEngine(fhePrivateKey, fheSearchPrivateKey);
}

function getEngine() :KryptoEngine {

  if (kryptoEngineInstance === null) {
    throw new Error('KryptoEngine has not been initialized');
  }

  return kryptoEngineInstance;
}

export default {
  init,
  getEngine
};
