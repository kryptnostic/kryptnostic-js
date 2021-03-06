# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.binary-utils', [
  'require'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  _      = require 'lodash'
  Logger = require 'kryptnostic.logger'

  logger = Logger.get('BinaryUtils')

  #
  # Utility functions for working with binary data.
  # Author: rbuckheit
  #

  # private
  # =======

  EMPTY_STRING = ''

  validateString = (arg) ->
    unless _.isString(arg)
      throw new Error 'argument is not a string'

  validateUint8 = (arg) ->
    unless arg.buffer?
      throw new Error 'argument is not a uint8 array'

  validateUint16 = (arg) ->
    unless arg.buffer?
      throw new Error 'argument is not a uint16 array'

  getCharCode = (c, maxSize) ->
    code = c.charCodeAt()
    if code >= maxSize
      throw new Error 'code outside of range!'
    else
      return code

  # hex
  # ===

  HEX_CHARS_PER_BYTE = 2
  HEX_SIZE_PER_CHAR  = 16

  hexToUint8 = (hex) ->
    validateString(hex)

    bytes = []
    for index in [0...hex.length] by HEX_CHARS_PER_BYTE
      hexByte = hex.substr(index, HEX_CHARS_PER_BYTE)
      bytes.push(parseInt(hexByte, HEX_SIZE_PER_CHAR))
    return new Uint8Array(bytes)

  stringToHex = (str) ->
    unless _.isString(str)
      throw new Error 'argument is not a string'

    str.split(EMPTY_STRING)
      .map((c) -> c.charCodeAt().toString(16))
      .join(EMPTY_STRING)

  # uint
  # ====

  UINT8_REPRESENTABLE_SIZE  = Math.pow(2, 8)
  UINT16_REPRESENTABLE_SIZE = Math.pow(2, 16)

  # cleans a uint8 array so that the underlying buffer byteLength
  # matches the array length exactly with no extra padding.
  cleanUint8Buffer = (arr) ->
    validateUint8(arr)

    if arr.length is arr.byteLength and arr.length is arr.buffer.byteLength
      return arr
    else
      raw = [0...arr.length].map((i) -> arr[i])
      return new Uint8Array(raw)

  uint8ToNumeric = (arr) ->
    validateUint8(arr)
    return [0...arr.length].map((i) -> arr[i])

  uint8ToString = (arr) ->
    validateUint8(arr)
    return [0...arr.length].map((i) -> String.fromCharCode(arr[i])).join(EMPTY_STRING)

  uint8ToBase64 = (arr) ->
    validateUint8(arr)
    return btoa(uint8ToString(arr))

  uint16ToString = (arr) ->
    validateUint16(arr)
    return [0...arr.length].map((i) -> String.fromCharCode(arr[i])).join(EMPTY_STRING)

  stringToUint8 = (string) ->
    validateString(string)
    return new Uint8Array(_.map(string, (c) -> getCharCode(c, UINT8_REPRESENTABLE_SIZE)))

  stringToUint16 = (string) ->
    validateString(string)
    return new Uint16Array(_.map(string, (c) -> getCharCode(c, UINT16_REPRESENTABLE_SIZE)))

  uint16ToUint8 = (arr) ->
    validateUint16(arr)
    return new Uint8Array(arr.buffer)

  uint8ToUint16 = (arr) ->
    validateUint8(arr)
    return new Uint16Array(arr.buffer)

  intToUint8 = (integer) ->
    rawBytes = []
    while integer > 0
      nextByte = integer & 0xff
      rawBytes.push(nextByte)
      integer = (integer - nextByte) / 256
    return new Uint8Array(rawBytes)

  joinUint8 = (arrays) ->
    targetLength = _.reduce(arrays, ((length, arr) -> length + arr.length), 0)
    buffer       = new Uint8Array(targetLength)
    copyIndex    = 0

    arrays.forEach (arr) ->
      for sublistIndex in [0...arr.length]
        buffer[copyIndex] = arr[sublistIndex]
        copyIndex += 1

    return buffer

  chunkUint8 = (array, chunkSizeBytes) ->
    validateUint8(array)

    arrays    = []
    copyIndex = 0
    buffer    = new Uint8Array(chunkSizeBytes)

    while copyIndex < array.length
      subarr = array.subarray(copyIndex, copyIndex + chunkSizeBytes)
      arrays.push(new Uint8Array(subarr))
      copyIndex += chunkSizeBytes

    return arrays

  return {
    chunkUint8
    cleanUint8Buffer
    hexToUint8
    intToUint8
    joinUint8
    stringToHex
    stringToUint16
    stringToUint8
    uint16ToString
    uint16ToUint8
    uint8ToString
    uint8ToBase64
    uint8ToUint16
    uint8ToNumeric
  }

# coffeelint: enable=cyclomatic_complexity
