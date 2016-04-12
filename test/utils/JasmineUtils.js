function toBeUint8ArrayOfSize() {

  return {
    compare: (value, expectedSize) => {

      const objectType = Object.prototype.toString.call(value);
      const isUint8Array = objectType === '[object Uint8Array]';
      const isCorrectSize = value.byteLength !== null && value.byteLength === expectedSize;

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

const MATCHERS = {
  toBeUint8ArrayOfSize
};

export { MATCHERS as JasmineMatchers };
