/*
 * @flow
 */

import * as WebCryptoAlgos from './constants/WebCryptoAlgorithms';
import * as WebCryptoOps from './constants/WebCryptoOperations';

const NOT_IMPLEMENTED = () => {
  throw new Error('not implemented');
};

/*
 * the concept of interfaces doesn't exist in JavaScript, so there's no "implements" keyword. intead...
 */
class WebCryptoInterface {
  constructor() {
    if (new.target === WebCryptoInterface) {
      throw new Error('WebCryptoInterface is an interface and cannot be instantiated');
    }
  }
}

WebCryptoInterface[WebCryptoAlgos.SHA_1] = {};

WebCryptoInterface[WebCryptoAlgos.SHA_256] = {};
WebCryptoInterface[WebCryptoAlgos.SHA_256][WebCryptoOps.DIGEST] = NOT_IMPLEMENTED;

WebCryptoInterface[WebCryptoAlgos.SHA_512] = {};
WebCryptoInterface[WebCryptoAlgos.SHA_512][WebCryptoOps.DIGEST] = NOT_IMPLEMENTED;

WebCryptoInterface[WebCryptoAlgos.PBKDF2_SHA_1] = {};
WebCryptoInterface[WebCryptoAlgos.PBKDF2_SHA_1][WebCryptoOps.IMPORT_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.PBKDF2_SHA_1][WebCryptoOps.DERIVE_CRYPTO_KEY] = NOT_IMPLEMENTED;

WebCryptoInterface[WebCryptoAlgos.HMAC_SHA_256] = {};
WebCryptoInterface[WebCryptoAlgos.HMAC_SHA_256][WebCryptoOps.GENERATE_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.HMAC_SHA_256][WebCryptoOps.IMPORT_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.HMAC_SHA_256][WebCryptoOps.SIGN] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.HMAC_SHA_256][WebCryptoOps.VERIFY] = NOT_IMPLEMENTED;

WebCryptoInterface[WebCryptoAlgos.AES_CTR_128] = {};
WebCryptoInterface[WebCryptoAlgos.AES_CTR_128][WebCryptoOps.GENERATE_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.AES_CTR_128][WebCryptoOps.EXPORT_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.AES_CTR_128][WebCryptoOps.ENCRYPT] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.AES_CTR_128][WebCryptoOps.DECRYPT] = NOT_IMPLEMENTED;

WebCryptoInterface[WebCryptoAlgos.AES_GCM_256] = {};
WebCryptoInterface[WebCryptoAlgos.AES_GCM_256][WebCryptoOps.GENERATE_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.AES_GCM_256][WebCryptoOps.EXPORT_CRYPTO_KEY] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.AES_GCM_256][WebCryptoOps.ENCRYPT] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.AES_GCM_256][WebCryptoOps.DECRYPT] = NOT_IMPLEMENTED;

WebCryptoInterface[WebCryptoAlgos.RSA_OAEP_SHA_256] = {};
WebCryptoInterface[WebCryptoAlgos.RSA_OAEP_SHA_256][WebCryptoOps.GENERATE_CRYPTO_KEY_PAIR] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.RSA_OAEP_SHA_256][WebCryptoOps.EXPORT_CRYPTO_KEY_PAIR] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.RSA_OAEP_SHA_256][WebCryptoOps.ENCRYPT] = NOT_IMPLEMENTED;
WebCryptoInterface[WebCryptoAlgos.RSA_OAEP_SHA_256][WebCryptoOps.DECRYPT] = NOT_IMPLEMENTED;

export default WebCryptoInterface;
