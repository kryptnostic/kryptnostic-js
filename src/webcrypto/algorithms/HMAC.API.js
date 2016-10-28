/*
 * @flow
 */

import SubtleCryptoAPI from '../SubtleCryptoAPI';
import WebCryptoInterface from '../WebCryptoInterface';

import {
  SHA_256 as SHA_256_API
} from './SHA.API';

import {
  HMAC_SHA_256 as ALGO_HMAC_SHA_256
} from '../constants/WebCryptoAlgorithms';

import {
  GENERATE_CRYPTO_KEY as OP_GENERATE_CRYPTO_KEY,
  IMPORT_CRYPTO_KEY as OP_IMPORT_CRYPTO_KEY,
  SIGN as OP_SIGN
} from '../constants/WebCryptoOperations';

/*
 *
 * HMAC_SHA_256 API
 *
 */

const HMAC_SHA_256 = WebCryptoInterface[ALGO_HMAC_SHA_256];

HMAC_SHA_256.ALGORITHM_DESCRIPTION = {
  algorithm: 'HMAC',
  keyUsages: [
    'sign',
    'verify'
  ],
  keyImportFormat: 'raw',
  isKeyExtractable: false,
  hash: SHA_256_API.ALGORITHM_DESCRIPTION
};

HMAC_SHA_256[OP_GENERATE_CRYPTO_KEY] = () :Promise<CryptoKey> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: HMAC_SHA_256.ALGORITHM_DESCRIPTION.algorithm,
    hash: {
      name: HMAC_SHA_256.ALGORITHM_DESCRIPTION.hash.algorithm
    }
  };

  return SubtleCryptoAPI
    .generateKey(
      algorithmProperties,
      HMAC_SHA_256.ALGORITHM_DESCRIPTION.isKeyExtractable,
      HMAC_SHA_256.ALGORITHM_DESCRIPTION.keyUsages
    )
    .then((aesCryptoKey :CryptoKey) => {
      return aesCryptoKey;
    })
    .catch(
      () => {}
    );
};

HMAC_SHA_256[OP_IMPORT_CRYPTO_KEY] = function importCryptoKey(keyAsUint8 :Uint8Array) :Promise<CryptoKey> {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: HMAC_SHA_256.ALGORITHM_DESCRIPTION.algorithm,
    hash: {
      name: HMAC_SHA_256.ALGORITHM_DESCRIPTION.hash.algorithm
    }
  };

  return SubtleCryptoAPI
    .importKey(
      HMAC_SHA_256.ALGORITHM_DESCRIPTION.keyImportFormat,
      keyAsUint8.buffer,
      algorithmProperties,
      HMAC_SHA_256.ALGORITHM_DESCRIPTION.isKeyExtractable,
      HMAC_SHA_256.ALGORITHM_DESCRIPTION.keyUsages
    )
    .then((cryptoKey :CryptoKey) => {
      return cryptoKey;
    })
    .catch(
      () => {}
    );
};

HMAC_SHA_256[OP_SIGN] = (cryptoKey :CryptoKey, data :Uint8Array) :Promise<Uint8Array> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  if (cryptoKey.algorithm.name !== HMAC_SHA_256.ALGORITHM_DESCRIPTION.algorithm
      || cryptoKey.algorithm.hash.name !== HMAC_SHA_256.ALGORITHM_DESCRIPTION.hash.algorithm) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: HMAC_SHA_256.ALGORITHM_DESCRIPTION.algorithm,
    hash: {
      name: HMAC_SHA_256.ALGORITHM_DESCRIPTION.hash.algorithm
    }
  };

  return SubtleCryptoAPI
    .sign(
      algorithmProperties,
      cryptoKey,
      data
    )
    .then((signature) => {
      const signatureAsUint8 = new Uint8Array(signature);
      return signatureAsUint8;
    })
    .catch(
      () => {}
    );
};

// HMAC_SHA_256[VERIFY] = (key :CryptoKey, signature :Uint8Array, data :Uint8Array) :Promise<boolean> => {
//
//   if (!SubtleCryptoAPI.isAvailable()) {
//     return Promise.reject();
//   }
//
//   throw new Error('not implemented!');
//
//   // const algorithmProperties = {
//   //   name: CryptoAlgorithms.HMAC.algorithm
//   // };
//   //
//   // return SubtleCryptoAPI
//   //   .verify(
//   //     algorithmProperties,
//   //     key,
//   //     signature,
//   //     data
//   //   )
//   //   .then((isValid) => {
//   //     return isValid;
//   //   })
//   //   .catch(
//   //     () => {}
//   //   );
// };

export {
  HMAC_SHA_256
};
