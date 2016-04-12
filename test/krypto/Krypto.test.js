import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';
import { JasmineMatchers } from '../utils/JasmineUtils';
import * as KryptoConstants from '../../src/KryptoConstants';
import * as MockDataUtils from '../utils/MockDataUtils';

const MOCK_SEARCH_TOKEN = MockDataUtils.generateRandomUint8Array(KryptoConstants.SEARCH_TOKEN_SIZE);

// krypto1 and krypto2 should compute as if they are exactly the same
let krypto1 = null;
let krypto2 = null;

describe('Krypto', () => {

  beforeAll(() => jasmine.addMatchers(JasmineMatchers));

  beforeEach(() => {

    krypto1 = new Krypto();
    krypto2 = new Krypto(
      new Uint8Array(krypto1.getPrivateKey()),
      new Uint8Array(krypto1.getSearchPrivateKey())
    );
  });

  afterEach(() => {

    krypto1 = null;
    krypto2 = null;
  });

  it('should generate the same FHE private key', () => {

    const fhePrivateKey1 = new Uint8Array(krypto1.getPrivateKey());
    const fhePrivateKey2 = new Uint8Array(krypto2.getPrivateKey());

    expect(fhePrivateKey1).toEqual(fhePrivateKey2);
  });

  it('should generate the same FHE search private key', () => {

    const fheSearchPrivateKey1 = new Uint8Array(krypto1.getSearchPrivateKey());
    const fheSearchPrivateKey2 = new Uint8Array(krypto2.getSearchPrivateKey());

    expect(fheSearchPrivateKey1).toEqual(fheSearchPrivateKey2);
  });

  it('should generate different FHE hash functions', () => {

    const fheHashFunction1 = new Uint8Array(krypto1.calculateClientHashFunction());
    const fheHashFunction2 = new Uint8Array(krypto2.calculateClientHashFunction());

    expect(fheHashFunction1).not.toEqual(fheHashFunction2);
  });

  it('should generate different ObjectIndexPairs', () => {

    const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
    const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());

    expect(objIndexPair1).not.toEqual(objIndexPair2);
  });

  it('should calculate the same ObjectIndexPair after using it to calculate the ObjectSearchPair', () => {

    const origObjIndexPair = new Uint8Array(krypto1.generateObjectIndexPair());
    const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(origObjIndexPair));
    const objIndexPair1 = new Uint8Array(krypto1.calculateObjectIndexPairFromObjectSearchPair(objSearchPair1));

    expect(objIndexPair1).toEqual(origObjIndexPair);

    krypto2 = new Krypto();
    const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(origObjIndexPair));
    const objIndexPair2 = new Uint8Array(krypto2.calculateObjectIndexPairFromObjectSearchPair(objSearchPair2));

    expect(objIndexPair2).toEqual(origObjIndexPair);
  });

  it('should calculate different ObjectSearchPairs from different ObjectIndexPairs', () => {

    const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
    const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
    const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(objIndexPair1));
    const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(objIndexPair2));

    expect(objSearchPair1).not.toEqual(objSearchPair2);
  });

  it('should calculate different ObjectSharePairs from different ObjectSearchPairs', () => {

    const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
    const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
    const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(objIndexPair1));
    const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(objIndexPair2));
    const objSharePair1 = new Uint8Array(krypto1.calculateObjectSharePairFromObjectSearchPair(objSearchPair1));
    const objSharePair2 = new Uint8Array(krypto2.calculateObjectSharePairFromObjectSearchPair(objSearchPair2));

    expect(objSharePair1).not.toEqual(objSharePair2);
  });

  it('should calculate the same ObjectSharePair from the same ObjectSearchPair', () => {

    const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
    const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
    const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(objIndexPair1));
    const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(objIndexPair2));

    expect(new Uint8Array(krypto1.calculateObjectSharePairFromObjectSearchPair(objSearchPair1)))
      .toEqual(new Uint8Array(krypto2.calculateObjectSharePairFromObjectSearchPair(objSearchPair1)));

    expect(new Uint8Array(krypto1.calculateObjectSharePairFromObjectSearchPair(objSearchPair2)))
      .toEqual(new Uint8Array(krypto2.calculateObjectSharePairFromObjectSearchPair(objSearchPair2)));
  });

  it('should calculate different ObjectSearchPairs from ObjectSharePairs', () => {

    const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
    const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
    const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(objIndexPair1));
    const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(objIndexPair2));
    const objSharePair1 = new Uint8Array(krypto1.calculateObjectSharePairFromObjectSearchPair(objSearchPair1));
    const objSharePair2 = new Uint8Array(krypto2.calculateObjectSharePairFromObjectSearchPair(objSearchPair2));

    expect(new Uint8Array(krypto1.calculateObjectSearchPairFromObjectSharePair(objSharePair1)))
      .not.toEqual(new Uint8Array(krypto2.calculateObjectSearchPairFromObjectSharePair(objSharePair2)));

    expect(new Uint8Array(krypto1.calculateObjectSearchPairFromObjectSharePair(objSharePair1)))
      .not.toEqual(new Uint8Array(krypto2.calculateObjectSearchPairFromObjectSharePair(objSharePair1)));

    expect(new Uint8Array(krypto1.calculateObjectSearchPairFromObjectSharePair(objSharePair2)))
      .not.toEqual(new Uint8Array(krypto2.calculateObjectSearchPairFromObjectSharePair(objSharePair2)));
  });

  it('should calculate the same metadata address', () => {

    const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
    const metatdataAddress1 = new Uint8Array(krypto1.calculateMetadataAddress(objIndexPair1, MOCK_SEARCH_TOKEN));
    const metatdataAddress2 = new Uint8Array(krypto2.calculateMetadataAddress(objIndexPair1, MOCK_SEARCH_TOKEN));

    expect(metatdataAddress1).toEqual(metatdataAddress2);

    const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
    const metatdataAddress3 = new Uint8Array(krypto1.calculateMetadataAddress(objIndexPair2, MOCK_SEARCH_TOKEN));
    const metatdataAddress4 = new Uint8Array(krypto2.calculateMetadataAddress(objIndexPair2, MOCK_SEARCH_TOKEN));

    expect(metatdataAddress3).toEqual(metatdataAddress4);
  });
});
