import * as KryptoConstants from '../../src/KryptoConstants';
import * as KryptoUtils from '../../src/KryptoUtils';
import * as MockDataUtils from '../utils/MockDataUtils';

/*
 * constants
 */

/* eslint-disable no-array-constructor, no-new-object */
const INVALID_INPUT = [
  undefined,
  null,
  [],
  new Array(),
  {},
  new Object(),
  -1,
  0,
  1,
  '',
  ' ',
  'invalid',
  /regex/
];
/* eslint-enable */

const INVALID_TYPED_ARRAYS = [
  new Int8Array(),
  new Int16Array(),
  new Uint16Array(),
  new Int32Array(),
  new Uint32Array(),
  new Float32Array(),
  new Float64Array()
];

/*
 * common tests that will be reused
 */

function testForInvalidInput(functionToTest) {

  it('should return false for invalid input', () => {

    // invoking with invalid input should not throw an exception
    INVALID_INPUT.forEach((input) =>
      expect(() => functionToTest(input)).not.toThrow()
    );

    INVALID_INPUT.forEach((input) =>
      expect(functionToTest(input)).toBe(false)
    );
  });
}

function testForInvalidTypedArrays(functionToTest) {

  it('should return false for invalid TypedArrays', () => {

    INVALID_TYPED_ARRAYS.forEach((input) =>
      expect(functionToTest(input)).toBe(false)
    );
  });
}

function testForIncorrectSize(functionToTest) {

  it('should return false for incorrectly-sized Uint8Array', () => {

    let badUint8 = new Uint8Array();
    expect(functionToTest(badUint8)).toBe(false);

    badUint8 = MockDataUtils.generateRandomUint8Array(100);
    expect(functionToTest(badUint8)).toBe(false);
  });
}

function testForCorrectSize(functionToTest, correctSize) {

  it('should return true for correctly-sized Uint8Array', () => {

    const correctlySizedUint8 = MockDataUtils.generateRandomUint8Array(correctSize);
    expect(functionToTest(correctlySizedUint8)).toBe(true);
  });
}

describe('KryptoUtils', () => {

  describe('isValidFHEPrivateKey()', () => {

    testForInvalidInput(KryptoUtils.isValidFHEPrivateKey);
    testForInvalidTypedArrays(KryptoUtils.isValidFHEPrivateKey);
    testForIncorrectSize(KryptoUtils.isValidFHEPrivateKey);
    testForCorrectSize(KryptoUtils.isValidFHEPrivateKey, KryptoConstants.FHE_PRIVATE_KEY_SIZE);
  });

  describe('isValidFHESearchPrivateKey()', () => {

    testForInvalidInput(KryptoUtils.isValidFHESearchPrivateKey);
    testForInvalidTypedArrays(KryptoUtils.isValidFHESearchPrivateKey);
    testForIncorrectSize(KryptoUtils.isValidFHESearchPrivateKey);
    testForCorrectSize(KryptoUtils.isValidFHESearchPrivateKey, KryptoConstants.FHE_SEARCH_PRIVATE_KEY_SIZE);
  });

  describe('isValidFHEHashFunction()', () => {

    testForInvalidInput(KryptoUtils.isValidFHEHashFunction);
    testForInvalidTypedArrays(KryptoUtils.isValidFHEHashFunction);
    testForIncorrectSize(KryptoUtils.isValidFHEHashFunction);
    testForCorrectSize(KryptoUtils.isValidFHEHashFunction, KryptoConstants.FHE_HASH_FUNCTION_SIZE);
  });

  describe('isValidObjectIndexPair()', () => {

    testForInvalidInput(KryptoUtils.isValidObjectIndexPair);
    testForInvalidTypedArrays(KryptoUtils.isValidObjectIndexPair);
    testForIncorrectSize(KryptoUtils.isValidObjectIndexPair);
    testForCorrectSize(KryptoUtils.isValidObjectIndexPair, KryptoConstants.OBJECT_INDEX_PAIR_SIZE);
  });

  describe('isValidObjectSearchPair()', () => {

    testForInvalidInput(KryptoUtils.isValidObjectSearchPair);
    testForInvalidTypedArrays(KryptoUtils.isValidObjectSearchPair);
    testForIncorrectSize(KryptoUtils.isValidObjectSearchPair);
    testForCorrectSize(KryptoUtils.isValidObjectSearchPair, KryptoConstants.OBJECT_SEARCH_PAIR_SIZE);
  });

  describe('isValidObjectSharePair()', () => {

    testForInvalidInput(KryptoUtils.isValidObjectSharePair);
    testForInvalidTypedArrays(KryptoUtils.isValidObjectSharePair);
    testForIncorrectSize(KryptoUtils.isValidObjectSharePair);
    testForCorrectSize(KryptoUtils.isValidObjectSharePair, KryptoConstants.OBJECT_SHARE_PAIR_SIZE);
  });

});
