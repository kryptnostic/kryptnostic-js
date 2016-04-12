/*
 * @flow
 */

/**
 * generates a random 8-bit unsigned integer [0, 255]
 *
 * @return {number} a random 8-bit unsigned integer
 */
export function generateRandom8bitInteger() :number {

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
export function generateRandomUint8Array(size :number) :Uint8Array {

  let i = 0;
  const uint8 = new Uint8Array(size);
  while (i < size) {

    uint8[i] = generateRandom8bitInteger();
    i++;
  }

  return uint8;
}
