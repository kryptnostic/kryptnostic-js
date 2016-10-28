/*
 * @flow
 */

import SubtleCryptoAPI from '../SubtleCryptoAPI';
import WebCryptoInterface from '../WebCryptoInterface';

import * as BinaryUtils from '../../utils/BinaryUtils';

import {
  forge
} from 'forge';

import {
  SHA_1 as ALGO_SHA_1,
  SHA_256 as ALGO_SHA_256,
  SHA_512 as ALGO_SHA_512
} from '../constants/WebCryptoAlgorithms';

import {
  DIGEST as OP_DIGEST
} from '../constants/WebCryptoOperations';

/*
 *
 * SHA_1 API
 *
 */

const SHA_1 = WebCryptoInterface[ALGO_SHA_1];

SHA_1.ALGORITHM_DESCRIPTION = {
  algorithm: 'SHA-1'
};

/*
 *
 * SHA_256 API
 *
 */

const SHA_256 = WebCryptoInterface[ALGO_SHA_256];

SHA_256.ALGORITHM_DESCRIPTION = {
  algorithm: 'SHA-256',
  hashSize: 256
};

SHA_256[OP_DIGEST] = (data :Uint8Array) :Promise<Uint8Array> => {

  if (!SubtleCryptoAPI.isAvailable()) {

    const hashBytes = forge.md.sha256
      .create()
      .update(data)
      .digest()
      .getBytes();

    const hashAsUint8 = BinaryUtils.stringToUint8(hashBytes);
    return Promise.resolve(hashAsUint8);
  }

  const algorithmProperties = {
    name: SHA_256.ALGORITHM_DESCRIPTION.algorithm
  };

  return SubtleCryptoAPI
    .digest(
      algorithmProperties,
      data.buffer
    )
    .then((hashedDataAsArrayBuffer) => {
      const hashedDataAsUint8 = new Uint8Array(hashedDataAsArrayBuffer);
      return hashedDataAsUint8;
    })
    .catch(
      () => {}
    );
};

/*
 *
 * SHA_512 API
 *
 */

const SHA_512 = WebCryptoInterface[ALGO_SHA_512];

SHA_512.ALGORITHM_DESCRIPTION = {
  algorithm: 'SHA-512',
  hashSize: 512
};

SHA_512[OP_DIGEST] = (data :Uint8Array) :Promise<Uint8Array> => {

  if (!SubtleCryptoAPI.isAvailable()) {

    const hashBytes = forge.md.sha512
      .create()
      .update(data)
      .digest()
      .getBytes();

    const hashAsUint8 = BinaryUtils.stringToUint8(hashBytes);
    return Promise.resolve(hashAsUint8);
  }

  const algorithmProperties = {
    name: SHA_512.ALGORITHM_DESCRIPTION.algorithm
  };

  return SubtleCryptoAPI
    .digest(
      algorithmProperties,
      data.buffer
    )
    .then((hashedDataAsArrayBuffer) => {
      const hashedDataAsUint8 = new Uint8Array(hashedDataAsArrayBuffer);
      return hashedDataAsUint8;
    })
    .catch(
      () => {}
    );
};

export {
  SHA_1,
  SHA_256,
  SHA_512
};
