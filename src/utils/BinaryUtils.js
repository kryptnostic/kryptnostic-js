/*
 * @flow
 */

/*
 * constants
 */

const EMPTY_STRING = '';
const EMPTY_UINT8_ARRAY = new Uint8Array(0);

/*
 * ideally, the Encoding API is available
 * https://developer.mozilla.org/en-US/docs/Web/API/Encoding_API
 */
const isEncodingAPIAvailable = (typeof TextDecoder !== 'undefined') && (typeof TextEncoder !== 'undefined');

/*
 * encode/decode a standard JavaScript string (UTF-16) into a UTF-8 string
 *
 * http://monsur.hossa.in/2012/07/20/utf-8-in-javascript.html
 */
export function encodeUTF8(str :string) :string {

  // forge.util.encodeUtf8() also uses this approach
  return unescape(encodeURIComponent(str));
}

export function decodeUTF8(str :string) :string {

  // forge.util.decodeUtf8() also uses this approach
  return decodeURIComponent(escape(str));
}

/**
 * converts a standard JavaScript string (UTF-16) to a Uint8Array
 *
 * @param str - the UTF-16 encoded string to convert
 * @return Uint8Array
 */
export function stringToUint8(str :string) :Uint8Array {

  if (typeof str !== 'string' && !Object.prototype.toString.call(str) !== '[object String]') {
    return EMPTY_UINT8_ARRAY;
  }

  // use the Encoding API
  if (isEncodingAPIAvailable) {
    const encoder = new TextEncoder();
    return encoder.encode(str);
  }

  /*
   * found this in forge.util.encodeUtf8()
   * UTF-8 encodes the given UTF-16 encoded string (a standard JavaScript string)
   */
  const utf8String = encodeUTF8(str);
  const byteCount = utf8String.length;

  const buffer = new ArrayBuffer(byteCount);
  const uint8 = new Uint8Array(buffer);
  for (let index = 0; index < byteCount; index++) {
    uint8[index] = utf8String.charCodeAt(index);
  }
  return uint8;
}

/**
 * converts a Uint8Array to a standard JavaScript string (UTF-16)
 *
 * @param uint8 - the Uint8Array to convert
 * @return String
 */
export function uint8ToString(uint8 :Uint8Array) :string {

  if (Object.prototype.toString.call(uint8) !== '[object Uint8Array]') {
    return EMPTY_STRING;
  }

  if (isEncodingAPIAvailable) {
    const decoder = new TextDecoder();
    return decoder.decode(uint8);
  }

  const encodedString = String.fromCharCode.apply(null, uint8);
  const decodedString = decodeUTF8(encodedString);
  return decodedString;
}
