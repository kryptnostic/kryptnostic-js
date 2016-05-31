/*
 * @flow
 */
import * as KryptoConstants from './KryptoConstants';

export function isValidFHEPrivateKey(fhePrivateKey :?Uint8Array) :boolean {

  return fhePrivateKey instanceof Uint8Array
    && fhePrivateKey.length === KryptoConstants.FHE_PRIVATE_KEY_SIZE
    && fhePrivateKey.byteLength === KryptoConstants.FHE_PRIVATE_KEY_SIZE;
}

export function isValidFHESearchPrivateKey(fheSearchPrivateKey :?Uint8Array) :boolean {

  return fheSearchPrivateKey instanceof Uint8Array
    && fheSearchPrivateKey.length === KryptoConstants.FHE_SEARCH_PRIVATE_KEY_SIZE
    && fheSearchPrivateKey.byteLength === KryptoConstants.FHE_SEARCH_PRIVATE_KEY_SIZE;
}

export function isValidFHEHashFunction(fheHashFunction :?Uint8Array) :boolean {

  return fheHashFunction instanceof Uint8Array
    && fheHashFunction.length === KryptoConstants.FHE_HASH_FUNCTION_SIZE
    && fheHashFunction.byteLength === KryptoConstants.FHE_HASH_FUNCTION_SIZE;
}

export function isValidObjectIndexPair(objectIndexPair :?Uint8Array) :boolean {

  return objectIndexPair instanceof Uint8Array
    && objectIndexPair.length === KryptoConstants.OBJECT_INDEX_PAIR_SIZE
    && objectIndexPair.byteLength === KryptoConstants.OBJECT_INDEX_PAIR_SIZE;
}

export function isValidObjectSearchPair(objectSearchPair :?Uint8Array) :boolean {

  return objectSearchPair instanceof Uint8Array
    && objectSearchPair.length === KryptoConstants.OBJECT_SEARCH_PAIR_SIZE
    && objectSearchPair.byteLength === KryptoConstants.OBJECT_SEARCH_PAIR_SIZE;
}

export function isValidObjectSharePair(objectSharePair :?Uint8Array) :boolean {

  return objectSharePair instanceof Uint8Array
    && objectSharePair.length === KryptoConstants.OBJECT_SHARE_PAIR_SIZE
    && objectSharePair.byteLength === KryptoConstants.OBJECT_SHARE_PAIR_SIZE;
}
