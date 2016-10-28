/*
 * since Babel supports Flow syntax, and ESLint is using the babel-eslint parser, ESLint will happily accept the
 * "declare" keyword, which means it won't complain about __VERSION__ being undefined, which makes us happy :)
 *
 * http://flowtype.org/docs/declarations.html
 */
declare var __VERSION__;

import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';

import MockDataUtils from '../test/utils/MockDataUtils';
MockDataUtils.generateRandomUint8Array(100);


const krypto = new Krypto();
krypto.getPrivateKey();


// import KryptoEngine from './KryptoEngine';
// const engine = KryptoEngine.getEngine();

module.exports = {
  __VERSION__
};

// import KryptnosticWorker from 'worker!./KryptnosticWorker.js';
//
// var kWorker = new KryptnosticWorker();
// kWorker.postMessage({});
// kWorker.onmessage = function(e) {
//   console.log('received message from worker');
//   console.log(e.data);
// };
//
// module.exports = {
//   __VERSION__
// };
