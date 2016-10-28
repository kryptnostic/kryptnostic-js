/*
 * @flow
 */

import WebCryptoInterface from '../webcrypto/WebCryptoInterface';

import * as WebCryptoAlgos from '../webcrypto/constants/WebCryptoAlgorithms';

import * as AES_API from '../webcrypto/algorithms/AES.API';
import * as RSA_API from '../webcrypto/algorithms/RSA.API';
import * as SHA_API from '../webcrypto/algorithms/SHA.API';
import * as HMAC_API from '../webcrypto/algorithms/HMAC.API';
import * as PBKDF2_API from '../webcrypto/algorithms/PBKDF2.API';

class WebCryptoWorkerAPI extends WebCryptoInterface {}

WebCryptoWorkerAPI[WebCryptoAlgos.SHA_256] = SHA_API.SHA_256;
WebCryptoWorkerAPI[WebCryptoAlgos.SHA_512] = SHA_API.SHA_512;
WebCryptoWorkerAPI[WebCryptoAlgos.PBKDF2_SHA_1] = PBKDF2_API.PBKDF2_SHA_1;
WebCryptoWorkerAPI[WebCryptoAlgos.HMAC_SHA_256] = HMAC_API.HMAC_SHA_256;
WebCryptoWorkerAPI[WebCryptoAlgos.AES_CTR_128] = AES_API.AES_CTR_128;
WebCryptoWorkerAPI[WebCryptoAlgos.AES_GCM_256] = AES_API.AES_GCM_256;
WebCryptoWorkerAPI[WebCryptoAlgos.RSA_OAEP_SHA_256] = RSA_API.RSA_OAEP_SHA_256;

export default WebCryptoWorkerAPI;
