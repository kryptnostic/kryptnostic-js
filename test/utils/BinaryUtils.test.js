import * as BinaryUtils from '../../src/utils/BinaryUtils';
import { JasmineMatchers } from './JasmineUtils';
import { TextDecoder, TextEncoder } from 'text-encoding';

/*
 * constants
 */

const EMPTY_STRING = '';
const EMPTY_UINT8_ARRAY = new Uint8Array(0);

/* eslint-disable no-array-constructor, no-new-object */
const INVALID_STRINGS = [
  undefined,
  null,
  [],
  new Array(),
  {},
  new Object(),
  -1,
  0,
  1,
  /regex/
];

const INVALID_UINT8_ARRAYS = INVALID_STRINGS.concat([
  '',
  ' ',
  'invalid'
]);

/* eslint-enable no-array-constructor, no-new-object */

/* eslint-disable max-len, no-useless-escape */
const VALID_INPUT = [
  {
    str: EMPTY_STRING,
    uint8: EMPTY_UINT8_ARRAY
  },
  {
    str: '1234567890!@#$%^&*()',
    uint8: new Uint8Array([49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41])
  },
  {
    str: 'hello',
    uint8: new Uint8Array([104, 101, 108, 108, 111])
  },
  {
    str: 'Здравей',
    uint8: new Uint8Array([208, 151, 208, 180, 209, 128, 208, 176, 208, 178, 208, 181, 208, 185])
  },
  {
    str: 'Χαίρετε',
    uint8: new Uint8Array([206, 167, 206, 177, 206, 175, 207, 129, 206, 181, 207, 132, 206, 181])
  },
  {
    str: '你好',
    uint8: new Uint8Array([228, 189, 160, 229, 165, 189])
  },
  {
    str: 'こんにちは',
    uint8: new Uint8Array([227, 129, 147, 227, 130, 147, 227, 129, 171, 227, 129, 161, 227, 129, 175])
  },
  {
    str: 'مرحبا',
    uint8: new Uint8Array([217, 133, 216, 177, 216, 173, 216, 168, 216, 167])
  },
  {
    str: 'नमस्ते',
    uint8: new Uint8Array([224, 164, 168, 224, 164, 174, 224, 164, 184, 224, 165, 141, 224, 164, 164, 224, 165, 135])
  },
  {
    str: 'ဟလို',
    uint8: new Uint8Array([225, 128, 159, 225, 128, 156, 225, 128, 173, 225, 128, 175])
  },
  {
    str: ',òMº_°£&è;*Å¹â\§B^s3b$',
    uint8: new Uint8Array([111, 62, 195, 159, 121, 195, 182, 195, 176, 68, 194, 150, 89, 112, 195, 128, 195, 137, 58, 195, 190, 194, 177, 194, 180, 117, 194, 162, 49, 107, 194, 185, 22, 195, 137, 194, 166, 195, 174, 86, 194, 179, 195, 136, 91, 194, 153, 34])
  }
];
/* eslint-enable max-len, no-useless-escape */

const encoder = new TextEncoder();
const decoder = new TextDecoder();

describe('BinaryUtils', () => {

  beforeAll(() => {
    jasmine.addMatchers(JasmineMatchers);
  });

  describe('stringToUint8()', () => {

    it('should correctly convert a JavaScript string (UTF-16) to Uint8Array', () => {

      VALID_INPUT.forEach((input) => {
        const outputAsUint8 = BinaryUtils.stringToUint8(input.str);
        const expectedUint8 = encoder.encode(input.str);
        expect(outputAsUint8).toBeUint8Array();
        expect(outputAsUint8).toEqual(expectedUint8);
      });
    });

    it('should correctly handle invalid input', () => {

      INVALID_STRINGS.forEach((input) => {
        expect(() => {
          BinaryUtils.stringToUint8(input);
        }).not.toThrow();
      });

      INVALID_STRINGS.forEach((input) => {
        const outputAsUint8 = BinaryUtils.stringToUint8(input);
        expect(outputAsUint8).toBeUint8Array();
        expect(outputAsUint8).toEqual(EMPTY_UINT8_ARRAY);
      });
    });
  });

  describe('uint8ToString()', () => {

    it('should correctly convert a Uint8Array into a JavaScript string (UTF-16)', () => {

      VALID_INPUT.forEach((input) => {
        const inputAsString = BinaryUtils.uint8ToString(input.uint8);
        const expectedString = decoder.decode(input.uint8);
        expect(inputAsString).toEqual(expectedString);
      });
    });

    it('should correctly handle invalid input', () => {

      INVALID_UINT8_ARRAYS.forEach((input) => {
        expect(() => {
          BinaryUtils.uint8ToString(input);
        }).not.toThrow();
      });

      INVALID_UINT8_ARRAYS.forEach((input) => {
        const outputAsString = BinaryUtils.uint8ToString(input);
        expect(outputAsString).toEqual(EMPTY_STRING);
      });
    });
  });

});
