/*
 * @flow
 */

/*
 * importing and referencing KryptoJS is ugly, but the webpack exports-loader makes it much nicer. specifically, we can export
 * global variables from inside krypto.js into the webpack global context under a new interface, "Krypto". now, we are able to
 * get a Krypto instance in two easy ways:
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

/*
 * the KryptoEngine singleton instance
 */
let kryptoEngineInstance = null;

/*
 * KryptoEngine is a singleton wrapper around KryptoJS. it exposes core functionality and adds convenient helper methods.
 */
class KryptoEngine {

  krypto :Krypto;

  constructor(krypto :Krypto) {

    if (kryptoEngineInstance !== null) {
      throw new Error('KryptoEngine has already been initialized');
    }

    this.krypto = krypto;
  }

  getFHEPrivateKey() :Uint8Array {

    return new Uint8Array(this.krypto.getPrivateKey());
  }

  getFHESearchPrivateKey() :Uint8Array {

    return new Uint8Array(this.krypto.getSearchPrivateKey());
  }

  getFHEHashFunction() :Uint8Array {

    return new Uint8Array(this.krypto.calculateClientHashFunction());
  }

}

function init(fhePrivateKey :?Uint8Array = null, fheSearchPrivateKey :?Uint8Array = null) {

  if (kryptoEngineInstance !== null) {
    throw new Error('KryptoEngine has already been initialized');
  }

  let krypto = null;
  if (fhePrivateKey && fheSearchPrivateKey) {
    krypto = new Krypto(fhePrivateKey, fheSearchPrivateKey);
  }
  else {
    krypto = new Krypto();
  }

  kryptoEngineInstance = new KryptoEngine(krypto);
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
