# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.binary-utils', [
  'require'
  'lodash'
  'forge'
  'kryptnostic.logger'
], (require) ->

  _      = require 'lodash'
  Logger = require 'kryptnostic.logger'
  Forge  = require 'forge'

  log = Logger.get('BinaryUtils')

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
    unless arg? and arg.buffer? and arg.length? and arg.byteLength?
      throw new Error 'argument is not a uint8 array'

  validateUint16 = (arg) ->
    unless arg? and arg.buffer? and arg.length? and arg.byteLength?
      throw new Error 'argument is not a uint16 array'

  getCharCode = (c, maxSize) ->
    code = c.charCodeAt()
    if code >= maxSize
      throw new Error 'code outside of range!'
    else
      # log.error('getCharCode', { c, code, str: String.fromCharCode(code) })
      return code

  # hex
  # ===

  HEX_CHARS_PER_BYTE = 2
  HEX_SIZE_PER_CHAR  = 16

  hexToUint = (hex) ->
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

  uint8ToString = (arr) ->
    validateUint8(arr)
    return _.chain([0...arr.length])
      .map((i) -> arr[i])
      .tap((arr) -> log.error('zz', arr))
      .map((uint16) -> String.fromCharCode(uint16))
      .value()
      .join(EMPTY_STRING)

    # return [0...arr.length].map((i) -> String.fromCharCode(arr[i])).join(EMPTY_STRING)

  uint16ToString = (arr) ->
    validateUint16(arr)
    # buffer = Forge.util.createBuffer(arr)
    # return buffer.toString('binary')
    # return _.chain([0...arr.length])
    #   .map((i) -> arr[i])
    #   .tap((arr) -> log.error('zz', arr))
    #   .map((uint16) -> String.fromCharCode(uint16))
    #   .value()
    #   .join(EMPTY_STRING)
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
    # buffer = new Uint18Array(arr.length)
    # [0...arr.length].forEach (i) ->
    #   if arr[i] >= UINT8_REPRESENTABLE_SIZE
    #     throw new Error 'loss of precision'
    #   buffer[i] = arr[i]
    # return buffer

  uint8ToUint16 = (arr) ->
    validateUint8(arr)
    return new Uint16Array(arr.buffer)
    # buffer = new Uint16Array(arr.length)
    # [0...arr.length].forEach (i) ->
    #   buffer[i] = arr[i]
    # return buffer

  joinUint = (arrays) ->
    targetLength = _.reduce(arrays, ((length, arr) -> length + arr.length), 0)
    buffer       = new Uint8Array(targetLength)
    i = 0
    arrays.forEach (arr) ->
      for j in [0...arr.length]
        buffer[i] = arr[j]
        i += 1

    return buffer

  chunkUint = (array, chunkSize) ->
    arrays = []
    buffer = new Uint8Array(chunkSize)
    copyIndex = 0

    [0...array.length].forEach (i) ->
      # copy element
      buffer[copyIndex] = array[i]
      copyIndex += 1

      # flush if needed
      chunkFull   = copyIndex is chunkSize
      lastElement = i is array.length - 1

      if chunkFull or lastElement
        arrays.push(buffer)
        buffer  = new Uint8Array(chunkSize)
        copyIndex = 0


    return arrays

  return {
    chunkUint
    hexToUint
    joinUint
    stringToHex
    stringToUint16
    stringToUint8
    uint16ToString
    uint16ToUint8
    uint8ToString
    uint8ToUint16
  }

# coffeelint: enable=cyclomatic_complexity
