/*
 * @flow
 */

class MockDataUtils {

  static FHE_PRIVATE_KEY_SIZE = 329760;
  static FHE_SEARCH_PRIVATE_KEY_SIZE = 4096;
  static FHE_HASH_FUNCTION_SIZE = 1060896;

  static OBJECT_INDEX_PAIR_SIZE = 2064;
  static OBJECT_SEARCH_PAIR_SIZE = 2080;
  static OBJECT_SHARE_PAIR_SIZE = 2064;

  static SEARCH_TOKEN_SIZE = 16;

  /**
   * generates a random 8-bit unsigned integer [0, 255]
   *
   * @return {number} a random 8-bit unsigned integer
   */
  static generateRandom8bitInteger() :number {

    const min = 0;
    const max = 255;
    return Math.floor(Math.random() * (max - min + 1) + min);
  }

  /**
   * generates a Uint8Array filled with random 8-bit unsigned integers
   *
   * @param  {number} size - the desired size of the Uint8Array
   * @return {Uint8Array} a random Uint8Array
   */
  static generateRandomUint8Array(size :number) :Uint8Array {

    let i = 0;
    const uint8 = new Uint8Array(size);
    while (i < size) {

      uint8[i] = MockDataUtils.generateRandom8bitInteger();
      i++;
    }

    return uint8;
  }

}

export default MockDataUtils;
