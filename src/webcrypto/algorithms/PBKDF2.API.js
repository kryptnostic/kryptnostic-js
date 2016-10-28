/*
 * @flow
 */

import SubtleCryptoAPI from '../SubtleCryptoAPI';
import WebCryptoInterface from '../WebCryptoInterface';

import {
  SHA_1 as SHA_1_API
} from './SHA.API';

import {
  PBKDF2_SHA_1 as ALGO_PBKDF2_SHA_1
} from '../constants/WebCryptoAlgorithms';

import {
  IMPORT_CRYPTO_KEY as OP_IMPORT_CRYPTO_KEY,
  DERIVE_CRYPTO_KEY as OP_DERIVE_CRYPTO_KEY
} from '../constants/WebCryptoOperations';

/*
 *
 * PBKDF2_SHA_256 API
 *
 */

const PBKDF2_SHA_1 = WebCryptoInterface[ALGO_PBKDF2_SHA_1];

PBKDF2_SHA_1.ALGORITHM_DESCRIPTION = {
  algorithm: 'PBKDF2',
  hash: SHA_1_API.ALGORITHM_DESCRIPTION,
  iterations: 128,
  keyUsages: [
    'deriveKey'
  ],
  keyExportFormat: 'raw',
  isKeyExtractable: false
};

PBKDF2_SHA_1[OP_IMPORT_CRYPTO_KEY] = (keyBytes :Uint8Array) :Promise<CryptoKey> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.algorithm
  };

  return SubtleCryptoAPI
    .importKey(
      PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.keyExportFormat,
      keyBytes,
      algorithmProperties,
      PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.isKeyExtractable,
      PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.keyUsages
    )
    .then((cryptoKey) => {
      return cryptoKey;
    })
    .catch(
      () => {}
    );
};

PBKDF2_SHA_1[OP_DERIVE_CRYPTO_KEY] = (
  masterCryptoKey :Object,
  derivingAlgorithmDescription :Object
) :Promise<CryptoKey> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const randomSalt = SubtleCryptoAPI.getRandomValues(new Uint8Array(128 / 8));
  const algorithmProperties = {
    name: PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.algorithm,
    hash: {
      name: PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.hash.algorithm
    },
    iterations: PBKDF2_SHA_1.ALGORITHM_DESCRIPTION.iterations,
    salt: randomSalt
  };

  const derivingAlgorithmProperties = {
    name: derivingAlgorithmDescription.algorithm,
    length: derivingAlgorithmDescription.keySize
  };

  return SubtleCryptoAPI
    .deriveKey(
      algorithmProperties,
      masterCryptoKey,
      derivingAlgorithmProperties,
      derivingAlgorithmDescription.isKeyExtractable,
      derivingAlgorithmDescription.keyUsages
    )
    .then((derivedCryptoKey) => {
      return derivedCryptoKey;
    })
    .catch(
      () => {}
    );
};

export {
  PBKDF2_SHA_1
};
