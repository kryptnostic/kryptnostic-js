import KryptoEngine from '../../src/KryptoEngine';
import * as KryptoEngineTestSuite from './KryptoEngineTestSuite';

import { JasmineMatchers } from '../utils/JasmineUtils';

describe('KryptoEngine - Initialize Without FHE Keys', () => {

  beforeAll(() => jasmine.addMatchers(JasmineMatchers));

  KryptoEngine.init();
  const engine = KryptoEngine.getEngine();

  KryptoEngineTestSuite.run(engine);

});
