/*
 * @flow
 */

const SHA_1 = 'SHA_1';
const SHA_256 = 'SHA_256';
const SHA_512 = 'SHA_512';
const PBKDF2_SHA_1 = 'PBKDF2_SHA_1';
const HMAC_SHA_256 = 'HMAC_SHA_256';
const AES_CTR_128 = 'AES_CTR_128';
const AES_GCM_256 = 'AES_GCM_256';
const RSA_OAEP_SHA_256 = 'RSA_OAEP_SHA_256';

function isValidAlgorithm(algorithm :string) {

  if (algorithm === SHA_1
      || algorithm === SHA_256
      || algorithm === SHA_512
      || algorithm === PBKDF2_SHA_1
      || algorithm === HMAC_SHA_256
      || algorithm === AES_CTR_128
      || algorithm === AES_GCM_256
      || algorithm === RSA_OAEP_SHA_256
    ) {

    return true;
  }

  return false;
}

export {
  SHA_1,
  SHA_256,
  SHA_512,
  PBKDF2_SHA_1,
  HMAC_SHA_256,
  AES_CTR_128,
  AES_GCM_256,
  RSA_OAEP_SHA_256,
  isValidAlgorithm
};
