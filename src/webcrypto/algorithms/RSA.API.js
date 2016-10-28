/*
 * @flow
 */

import SubtleCryptoAPI from '../SubtleCryptoAPI';
import WebCryptoInterface from '../WebCryptoInterface';

import {
  SHA_256 as SHA_256_API
} from './SHA.API';

import {
  RSA_OAEP_SHA_256 as ALGO_RSA_OAEP_SHA_256
} from '../constants/WebCryptoAlgorithms';

import {
  GENERATE_CRYPTO_KEY_PAIR as OP_GENERATE_CRYPTO_KEY_PAIR
} from '../constants/WebCryptoOperations';

/*
 *
 * RSA_OAEP API
 *
 */

const RSA_OAEP_SHA_256 = WebCryptoInterface[ALGO_RSA_OAEP_SHA_256];

RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION = {
  algorithm: 'RSA-OAEP',
  cipher: 'RSA',
  mode: 'OAEP',
  modulusLength: 4096,
  publicExponent: new Uint8Array([0x01, 0x00, 0x01]), // == 65537
  hash: SHA_256_API.ALGORITHM_DESCRIPTION,
  keyUsages: [
    'encrypt',
    'decrypt',
    'wrapKey'
  ],
  publicKeyExportFormat: 'spki',
  privateKeyExportFormat: 'pkcs8',
  isKeyExtractable: true
};

RSA_OAEP_SHA_256[OP_GENERATE_CRYPTO_KEY_PAIR] = function generateCryptoKeyPair() :Promise {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION.algorithm,
    modulusLength: RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION.modulusLength,
    publicExponent: RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION.publicExponent,
    hash: {
      name: RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION.hash.algorithm
    }
  };

  return SubtleCryptoAPI
    .generateKey(
      algorithmProperties,
      RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION.isKeyExtractable,
      RSA_OAEP_SHA_256.ALGORITHM_DESCRIPTION.keyUsages
    )
    .then((cryptoKeyPair :CryptoKeyPair) => {
      return cryptoKeyPair;
    })
    .catch(
      () => {}
    );
};

// RSA_OAEP_SHA_256.exportCryptoKeyPair = function exportCryptoKeyPair(cryptoKeyPair :CryptoKeyPair) :Promise {
//
// }

export {
  RSA_OAEP_SHA_256
};
