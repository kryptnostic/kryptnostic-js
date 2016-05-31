import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';
import KryptoEngine from '../../src/krypto/KryptoEngine';
import * as KryptoEngineTestSuite from './KryptoEngineTestSuite';

import { JasmineMatchers } from '../utils/JasmineUtils';

/*
 * mock data
 */

const kryptoForMockData = new Krypto();
const MOCK_FHE_PRIVATE_KEY = new Uint8Array(kryptoForMockData.getPrivateKey());
const MOCK_FHE_SEARCH_PRIVATE_KEY = new Uint8Array(kryptoForMockData.getSearchPrivateKey());

describe('KryptoEngine - Initialize With FHE Keys', () => {

  beforeAll(() => jasmine.addMatchers(JasmineMatchers));

  KryptoEngine.init(MOCK_FHE_PRIVATE_KEY, MOCK_FHE_SEARCH_PRIVATE_KEY);

  KryptoEngineTestSuite.run(
    KryptoEngine.getEngine(),
    MOCK_FHE_PRIVATE_KEY,
    MOCK_FHE_SEARCH_PRIVATE_KEY
  );

});
