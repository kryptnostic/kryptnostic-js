/* eslint-disable no-console */

/*
 * @flow
 */
declare var __VERSION__;

import WebCryptoAPI from './webcrypto/WebCryptoAPI';
import * as BinaryUtils from './utils/BinaryUtils';

WebCryptoAPI.SHA_256
  .digest(BinaryUtils.stringToUint8('ping'))
  .then((hash) => {
    console.log('ping', hash);
    return hash;
  })
  .catch((e) => {
    console.log('caught error');
    console.error(e);
  });

WebCryptoAPI.SHA_512
  .digest(BinaryUtils.stringToUint8('hello'))
  .then((hash) => {
    console.log('hello', hash);
    return hash;
  })
  .catch((e) => {
    console.log('caught error');
    console.error(e);
  });

module.exports = {
  __VERSION__
};
