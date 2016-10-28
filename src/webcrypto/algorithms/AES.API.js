/*
 * @flow
 */

import SubtleCryptoAPI from '../SubtleCryptoAPI';
import WebCryptoInterface from '../WebCryptoInterface';

import {
  AES_CTR_128 as ALGO_AES_CTR_128,
  AES_GCM_256 as ALGO_AES_GCM_256
} from '../constants/WebCryptoAlgorithms';

import {
  ENCRYPT as OP_ENCRYPT,
  DECRYPT as OP_DECRYPT,
  GENERATE_CRYPTO_KEY as OP_GENERATE_CRYPTO_KEY,
  EXPORT_CRYPTO_KEY as OP_EXPORT_CRYPTO_KEY
} from '../constants/WebCryptoOperations';

/*
 * constants
 */
const BITS_PER_BYTE = 8;
const IV_96 = 96;
const COUNTER_128 = 128;

/*
 *
 * AES_CTR_128 API
 *
 */

const AES_CTR_128 = WebCryptoInterface[ALGO_AES_CTR_128];

AES_CTR_128.ALGORITHM_DESCRIPTION = {
  algorithm: 'AES-CTR',
  cipher: 'AES',
  mode: 'CTR',
  keySize: 128,
  keyUsages: [
    'encrypt',
    'decrypt'
  ],
  keyExportFormat: 'raw',
  isKeyExtractable: true
};

AES_CTR_128[OP_GENERATE_CRYPTO_KEY] = () :Promise<CryptoKey> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: AES_CTR_128.ALGORITHM_DESCRIPTION.algorithm,
    length: AES_CTR_128.ALGORITHM_DESCRIPTION.keySize
  };

  return SubtleCryptoAPI
    .generateKey(
      algorithmProperties,
      AES_CTR_128.ALGORITHM_DESCRIPTION.isKeyExtractable,
      AES_CTR_128.ALGORITHM_DESCRIPTION.keyUsages
    )
    .then((aesCryptoKey :CryptoKey) => {
      return aesCryptoKey;
    })
    .catch(
      () => {}
    );
};

AES_CTR_128[OP_EXPORT_CRYPTO_KEY] = (aesCryptoKey :CryptoKey) :Promise<any> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  return SubtleCryptoAPI
    .exportKey(
      AES_CTR_128.ALGORITHM_DESCRIPTION.keyExportFormat,
      aesCryptoKey
    )
    .then((aesCryptoKeyBytes) => {
      const aesCryptoKeyAsUint8 = new Uint8Array(aesCryptoKeyBytes);
      return aesCryptoKeyAsUint8;
    })
    .catch(
      () => {}
    );
};

AES_CTR_128[OP_ENCRYPT] = (aesCryptoKey :CryptoKey, plaintextAsUint8 :Uint8Array) :Promise<any> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const randomCounter = SubtleCryptoAPI.getRandomValues(new Uint8Array(COUNTER_128 / BITS_PER_BYTE));
  const algorithmProperties = {
    name: AES_CTR_128.ALGORITHM_DESCRIPTION.algorithm,
    length: AES_CTR_128.ALGORITHM_DESCRIPTION.keySize,
    counter: randomCounter
  };

  return SubtleCryptoAPI
    .encrypt(
      algorithmProperties,
      aesCryptoKey,
      plaintextAsUint8.buffer
    )
    .then((encryptedDataAsArrayBuffer) => {
      const encryptedDataAsUint8 = new Uint8Array(encryptedDataAsArrayBuffer);
      return {
        counter: randomCounter,
        data: encryptedDataAsUint8
      };
    })
    .catch(
      () => {}
    );
};

AES_CTR_128[OP_DECRYPT] = (aesCryptoKey :CryptoKey, ciphertextStuff :Object) :Promise<Uint8Array> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: AES_CTR_128.ALGORITHM_DESCRIPTION.algorithm,
    length: AES_CTR_128.ALGORITHM_DESCRIPTION.keySize,
    counter: ciphertextStuff.counter
  };

  return SubtleCryptoAPI
    .decrypt(
      algorithmProperties,
      aesCryptoKey,
      ciphertextStuff.data.buffer
    )
    .then((decryptedDataAsArrayBuffer) => {
      const decryptedDataAsUint8 = new Uint8Array(decryptedDataAsArrayBuffer);
      return decryptedDataAsUint8;
    })
    .catch(
      () => {}
    );
};

/*
 *
 * AES_GCM_256 API
 *
 */

const AES_GCM_256 = WebCryptoInterface[ALGO_AES_GCM_256];

AES_GCM_256.ALGORITHM_DESCRIPTION = {
  algorithm: 'AES-GCM',
  cipher: 'AES',
  mode: 'GCM',
  keySize: 256,
  keyUsages: [
    'encrypt',
    'decrypt'
  ],
  keyExportFormat: 'raw',
  isKeyExtractable: true
};

AES_GCM_256[OP_GENERATE_CRYPTO_KEY] = () :Promise<CryptoKey> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: AES_GCM_256.ALGORITHM_DESCRIPTION.algorithm,
    length: AES_GCM_256.ALGORITHM_DESCRIPTION.keySize
  };

  return SubtleCryptoAPI
    .generateKey(
      algorithmProperties,
      AES_GCM_256.ALGORITHM_DESCRIPTION.isKeyExtractable,
      AES_GCM_256.ALGORITHM_DESCRIPTION.keyUsages
    )
    .then((cryptoKey :CryptoKey) => {
      return cryptoKey;
    })
    .catch(
      () => {}
    );
};

AES_GCM_256[OP_EXPORT_CRYPTO_KEY] = (aesCryptoKey :CryptoKey) :Promise<any> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  return SubtleCryptoAPI
    .exportKey(
      AES_GCM_256.ALGORITHM_DESCRIPTION.keyExportFormat,
      aesCryptoKey
    )
    .then((aesCryptoKeyBytes) => {
      const aesCryptoKeyAsUint8 = new Uint8Array(aesCryptoKeyBytes);
      return aesCryptoKeyAsUint8;
    })
    .catch(
      () => {}
    );
};

AES_GCM_256[OP_ENCRYPT] = (aesCryptoKey :CryptoKey, plaintextAsUint8 :Uint8Array) :Promise<any> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const randomIV = SubtleCryptoAPI.getRandomValues(new Uint8Array(IV_96 / BITS_PER_BYTE));
  const algorithmProperties = {
    name: AES_GCM_256.ALGORITHM_DESCRIPTION.algorithm,
    iv: randomIV
  };

  return SubtleCryptoAPI
    .encrypt(
      algorithmProperties,
      aesCryptoKey,
      plaintextAsUint8.buffer
    )
    .then((encryptedDataAsArrayBuffer) => {
      const encryptedDataAsUint8 = new Uint8Array(encryptedDataAsArrayBuffer);
      return {
        iv: randomIV,
        data: encryptedDataAsUint8
      };
    })
    .catch(
      () => {}
    );
};

AES_GCM_256[OP_DECRYPT] = (aesCryptoKey :CryptoKey, ciphertextStuff :Object) :Promise<Uint8Array> => {

  if (!SubtleCryptoAPI.isAvailable()) {
    return Promise.reject();
  }

  const algorithmProperties = {
    name: AES_GCM_256.ALGORITHM_DESCRIPTION.algorithm,
    iv: ciphertextStuff.iv
  };

  return SubtleCryptoAPI
    .decrypt(
      algorithmProperties,
      aesCryptoKey,
      ciphertextStuff.data.buffer
    )
    .then((decryptedDataAsArrayBuffer) => {
      const decryptedDataAsUint8 = new Uint8Array(decryptedDataAsArrayBuffer);
      return decryptedDataAsUint8;
    })
    .catch(
      () => {}
    );
};

export {
  AES_CTR_128,
  AES_GCM_256
};
