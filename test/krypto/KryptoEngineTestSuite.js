import * as KryptoConstants from '../../src/KryptoConstants';
import * as MockDataUtils from '../utils/MockDataUtils';

const MOCK_SEARCH_TOKEN = MockDataUtils.generateRandomUint8Array(KryptoConstants.SEARCH_TOKEN_SIZE);

let engine = null;

function testEngineInstanceAPI() {

  it('should not expose private Krypto instance', () =>
    expect(engine.kryptoInstance).not.toBeDefined()
  );

  it('should have getFHEPrivateKey()', () =>
    expect(engine.getFHEPrivateKey).toEqual(jasmine.any(Function))
  );

  it('should have getFHESearchPrivateKey()', () =>
    expect(engine.getFHESearchPrivateKey).toEqual(jasmine.any(Function))
  );

  it('should have getFHEHashFunction()', () =>
    expect(engine.getFHEHashFunction).toEqual(jasmine.any(Function))
  );

  it('should have generateObjectIndexPair()', () =>
    expect(engine.generateObjectIndexPair).toEqual(jasmine.any(Function))
  );

  it('should have generateObjectSearchPair()', () =>
    expect(engine.generateObjectSearchPair).toEqual(jasmine.any(Function))
  );

  it('should have calculateObjectIndexPairFromObjectSearchPair()', () =>
    expect(engine.calculateObjectIndexPairFromObjectSearchPair).toEqual(jasmine.any(Function))
  );

  it('should have calculateObjectSearchPairFromObjectIndexPair()', () =>
    expect(engine.calculateObjectSearchPairFromObjectIndexPair).toEqual(jasmine.any(Function))
  );

  it('should have calculateObjectSearchPairFromObjectSharePair()', () =>
    expect(engine.calculateObjectSearchPairFromObjectSharePair).toEqual(jasmine.any(Function))
  );

  it('should have calculateObjectSharePairFromObjectSearchPair()', () =>
    expect(engine.calculateObjectSharePairFromObjectSearchPair).toEqual(jasmine.any(Function))
  );

  it('should have calculateEncryptedSearchToken()', () =>
    expect(engine.calculateEncryptedSearchToken).toEqual(jasmine.any(Function))
  );

  it('should have calculateMetadataAddress()', () =>
    expect(engine.calculateMetadataAddress).toEqual(jasmine.any(Function))
  );
}

function testFHEPrivateKey(expectedFHEPrivateKey) {

  const fhePrivateKey = engine.getFHEPrivateKey();

  if (expectedFHEPrivateKey) {
    it('should use the given FHE private key', () =>
      expect(fhePrivateKey).toEqual(expectedFHEPrivateKey)
    );
  }
  else {
    it('should generate a valid FHE private key', () =>
      expect(fhePrivateKey).toBeUint8ArrayOfSize(KryptoConstants.FHE_PRIVATE_KEY_SIZE)
    );
  }
}

function testFHESearchPrivateKey(expectedFHESearchPrivateKey) {

  const fheSearchPrivateKey = engine.getFHESearchPrivateKey();

  if (expectedFHESearchPrivateKey) {
    it('should use the given FHE search private key', () =>
      expect(fheSearchPrivateKey).toEqual(expectedFHESearchPrivateKey)
    );
  }
  else {
    it('should generate a valid FHE search private key', () =>
      expect(fheSearchPrivateKey).toBeUint8ArrayOfSize(KryptoConstants.FHE_SEARCH_PRIVATE_KEY_SIZE)
    );
  }
}

function testFHEHashFunction() {

  it('should generate a valid FHE hash function', () => {

    const fheHashFunction = engine.getFHEHashFunction();
    expect(fheHashFunction).toBeUint8ArrayOfSize(KryptoConstants.FHE_HASH_FUNCTION_SIZE);
  });
}

function testObjectIndexPair() {

  it('should generate a valid ObjectIndexPair', () => {

    const objIndexPair = engine.generateObjectIndexPair();
    expect(objIndexPair).toBeUint8ArrayOfSize(KryptoConstants.OBJECT_INDEX_PAIR_SIZE);
  });
}

function testObjectSearchPair() {

  it('should generate a valid ObjectSearchPair', () => {

    const objSearchPair = engine.generateObjectSearchPair();
    expect(objSearchPair).toBeUint8ArrayOfSize(KryptoConstants.OBJECT_SEARCH_PAIR_SIZE);
  });

  it('should calculate a valid ObjectSearchPair', () => {

    const objIndexPair = engine.generateObjectIndexPair();
    const objSearchPair = engine.calculateObjectSearchPairFromObjectIndexPair(objIndexPair);
    expect(objSearchPair).toBeUint8ArrayOfSize(KryptoConstants.OBJECT_SEARCH_PAIR_SIZE);
  });
}

function testObjectSharePair() {

  it('should calculate a valid ObjectSharePair', () => {

    const objIndexPair = engine.generateObjectIndexPair();
    const objSearchPair = engine.calculateObjectSearchPairFromObjectIndexPair(objIndexPair);
    const objSharePair = engine.calculateObjectSharePairFromObjectSearchPair(objSearchPair);
    expect(objSharePair).toBeUint8ArrayOfSize(KryptoConstants.OBJECT_SHARE_PAIR_SIZE);
  });
}

function testEncryptedSearchToken() {

  it('should calculate a valid encrypted search token', () => {

    const encryptedSearchToken = engine.calculateEncryptedSearchToken(MOCK_SEARCH_TOKEN);
    expect(encryptedSearchToken).toBeUint8ArrayOfSize(KryptoConstants.ENCRYPTED_SEARCH_TOKEN_SIZE);
  });
}

function testMetadataAddress() {

  it('should calculate a valid metadata address', () => {

    const objIndexPair = engine.generateObjectIndexPair();
    const metatdataAddress = engine.calculateMetadataAddress(objIndexPair, MOCK_SEARCH_TOKEN);
    expect(metatdataAddress).toBeUint8ArrayOfSize(KryptoConstants.METADATA_ADDRESS_SIZE);
  });
}

export function run(kryptoEngineInstance, fhePrivateKey, fheSearchPrivateKey) {

  engine = kryptoEngineInstance;

  testEngineInstanceAPI();
  testFHEPrivateKey(fhePrivateKey);
  testFHESearchPrivateKey(fheSearchPrivateKey);
  testFHEHashFunction();
  testObjectIndexPair();
  testObjectSearchPair();
  testObjectSharePair();
  testEncryptedSearchToken();
  testMetadataAddress();
}
