import { Krypto } from 'exports?Krypto=Module.KryptnosticClient!krypto-js';

import MockDataUtils from '../utils/MockDataUtils';

/*
 * mock data
 */
const kryptoForMockData = new Krypto();
const MOCK_FHE_PRIVATE_KEY = new Uint8Array(kryptoForMockData.getPrivateKey());
const MOCK_FHE_SEARCH_PRIVATE_KEY = new Uint8Array(kryptoForMockData.getSearchPrivateKey());

const MOCK_SEARCH_TOKEN = MockDataUtils.generateRandomUint8Array(MockDataUtils.SEARCH_TOKEN_SIZE);

describe('Krypto', () => {

  beforeEach(() => {

    jasmine.addMatchers({
      /* jscs:disable requireShorthandArrowFunctions, requirePaddingNewlinesInBlocks */
      /* eslint-disable arrow-body-style */
      toBeUint8ArrayOfSize: () => {
        return {
          compare: (value, expectedSize) => {

            const objectType = Object.prototype.toString.call(value);
            const isUint8Array = objectType === '[object Uint8Array]';
            const isCorrectSize = (value.byteLength !== null) && value.byteLength === expectedSize;

            const result = {
              pass: isUint8Array && isCorrectSize,
              message: undefined
            };

            if (!result.pass) {
              if (!isUint8Array && !isCorrectSize) {
                result.message = `
                  expected an Uint8Array of size ${expectedSize},
                  but got ${objectType} of size ${value.byteLength}
                `;
              }
              else if (!isUint8Array) {
                result.message = `expected an Uint8Array, but got ${objectType}`;
              }
              else if (!isCorrectSize) {
                result.message = `expected an Uint8Array of size ${expectedSize}, but got size ${value.byteLength}`;
              }
              else {
                result.message = `expected an Uint8Array of size ${expectedSize}, but got ${value}`;
              }
            }

            return result;
          }
        };
      }
      /* jscs:enable */
      /* eslint-enable */
    });
  });

  describe('initialization with/without FHE keys', () => {

    let krypto1 = null;
    let krypto2 = null;

    beforeEach(() => {

      krypto1 = new Krypto();
      krypto2 = new Krypto(MOCK_FHE_PRIVATE_KEY, MOCK_FHE_SEARCH_PRIVATE_KEY);
    });

    afterEach(() => {

      krypto1 = null;
      krypto2 = null;
    });

    it('should generate a valid FHE private key, Uint8Array of length 329760', () => {

      const fhePrivateKey1 = new Uint8Array(krypto1.getPrivateKey());
      expect(fhePrivateKey1).toBeUint8ArrayOfSize(MockDataUtils.FHE_PRIVATE_KEY_SIZE);

      const fhePrivateKey2 = new Uint8Array(krypto2.getPrivateKey());
      expect(fhePrivateKey2).toBeUint8ArrayOfSize(MockDataUtils.FHE_PRIVATE_KEY_SIZE);
      expect(fhePrivateKey2).toEqual(MOCK_FHE_PRIVATE_KEY);
    });

    it('should generate a valid FHE search private key, Uint8Array of length 4096', () => {

      const fheSearchPrivateKey1 = new Uint8Array(krypto1.getSearchPrivateKey());
      expect(fheSearchPrivateKey1).toBeUint8ArrayOfSize(MockDataUtils.FHE_SEARCH_PRIVATE_KEY_SIZE);

      const fheSearchPrivateKey2 = new Uint8Array(krypto2.getSearchPrivateKey());
      expect(fheSearchPrivateKey2).toBeUint8ArrayOfSize(MockDataUtils.FHE_SEARCH_PRIVATE_KEY_SIZE);
      expect(fheSearchPrivateKey2).toEqual(MOCK_FHE_SEARCH_PRIVATE_KEY);
    });

    it('should calculate a valid FHE hash function, Uint8Array of length 1060896', () => {

      const fheHashFunction1 = new Uint8Array(krypto1.calculateClientHashFunction());
      expect(fheHashFunction1).toBeUint8ArrayOfSize(MockDataUtils.FHE_HASH_FUNCTION_SIZE);

      const fheHashFunction2 = new Uint8Array(krypto2.calculateClientHashFunction());
      expect(fheHashFunction2).toBeUint8ArrayOfSize(MockDataUtils.FHE_HASH_FUNCTION_SIZE);
    });

    it('should calculate a valid ObjectIndexPair, Uint8Array of length 2064', () => {

      const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
      expect(objIndexPair1).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_INDEX_PAIR_SIZE);

      const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
      expect(objIndexPair2).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_INDEX_PAIR_SIZE);
    });

    it('should calculate a valid ObjectSearchPair, Uint8Array of length 2080', () => {

      const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
      const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(objIndexPair1));
      expect(objSearchPair1).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_SEARCH_PAIR_SIZE);

      const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
      const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(objIndexPair2));
      expect(objSearchPair2).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_SEARCH_PAIR_SIZE);
    });

    it('should calculate a valid ObjectSharePair, Uint8Array of length 2064', () => {

      const objIndexPair1 = new Uint8Array(krypto1.generateObjectIndexPair());
      const objSearchPair1 = new Uint8Array(krypto1.calculateObjectSearchPairFromObjectIndexPair(objIndexPair1));
      const objSharePair1 = new Uint8Array(krypto1.calculateObjectSharePairFromObjectSearchPair(objSearchPair1));
      expect(objSharePair1).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_SHARE_PAIR_SIZE);

      const objIndexPair2 = new Uint8Array(krypto2.generateObjectIndexPair());
      const objSearchPair2 = new Uint8Array(krypto2.calculateObjectSearchPairFromObjectIndexPair(objIndexPair2));
      const objSharePair2 = new Uint8Array(krypto2.calculateObjectSharePairFromObjectSearchPair(objSearchPair2));
      expect(objSharePair2).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_SHARE_PAIR_SIZE);
    });
  });

  describe('verify mathematical correctness', () => {

    // krypto1 and krypto2 should compute as if they are exactly the same
    let krypto1 = null;
    let krypto2 = null;

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

    it('should calculate different FHE hash functions', () => {

      const fheHashFunction1 = new Uint8Array(krypto1.calculateClientHashFunction());
      const fheHashFunction2 = new Uint8Array(krypto2.calculateClientHashFunction());

      expect(fheHashFunction1).not.toEqual(fheHashFunction2);
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

    it('should calculate different ObjectIndexPairs', () => {

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
  });

});
