import KryptoEngine from '../../src/krypto/KryptoEngine';
import * as KryptoEngineTestSuite from './KryptoEngineTestSuite';

import { JasmineMatchers } from '../utils/JasmineUtils';

describe('KryptoEngine - Initialize Without FHE Keys', () => {

  beforeAll(() => jasmine.addMatchers(JasmineMatchers));

  KryptoEngine.init();

  KryptoEngineTestSuite.run(
    KryptoEngine.getEngine()
  );

});
