/*
 * @flow
 */

const ENCRYPT = 'encrypt';
const DECRYPT = 'decrypt';
const DIGEST = 'digest';
const SIGN = 'sign';
const VERIFY = 'verify';
const GENERATE_CRYPTO_KEY = 'generateCryptoKey';
const GENERATE_CRYPTO_KEY_PAIR = 'generateCryptoKeyPair';
const IMPORT_CRYPTO_KEY = 'importCryptoKey';
const EXPORT_CRYPTO_KEY = 'exportCryptoKey';
const EXPORT_CRYPTO_KEY_PAIR = 'exportCryptoKeyPair';
const DERIVE_CRYPTO_KEY = 'deriveCryptoKey';
const WRAP_CRYPTO_KEY = 'wrapCryptoKey';
const UNWRAP_CRYPTO_KEY = 'unwrapCryptoKey';

function isValidOperation(operation :string) {

  if (operation === ENCRYPT
      || operation === DECRYPT
      || operation === DIGEST
      || operation === SIGN
      || operation === VERIFY
      || operation === GENERATE_CRYPTO_KEY
      || operation === GENERATE_CRYPTO_KEY_PAIR
      || operation === IMPORT_CRYPTO_KEY
      || operation === EXPORT_CRYPTO_KEY
      || operation === EXPORT_CRYPTO_KEY_PAIR
      || operation === DERIVE_CRYPTO_KEY
      || operation === WRAP_CRYPTO_KEY
      || operation === UNWRAP_CRYPTO_KEY) {

    return true;
  }

  return false;
}

export {
  ENCRYPT,
  DECRYPT,
  DIGEST,
  SIGN,
  VERIFY,
  GENERATE_CRYPTO_KEY,
  GENERATE_CRYPTO_KEY_PAIR,
  IMPORT_CRYPTO_KEY,
  EXPORT_CRYPTO_KEY,
  EXPORT_CRYPTO_KEY_PAIR,
  DERIVE_CRYPTO_KEY,
  WRAP_CRYPTO_KEY,
  UNWRAP_CRYPTO_KEY,
  isValidOperation
};
