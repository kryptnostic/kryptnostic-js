define 'kryptnostic.binary-utils', [
  'require'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  _      = require 'lodash'
  Logger = require 'kryptnostic.logger'

  log = Logger.get('BinaryUtils')

  EMPTY_STRING = ''

  #
  # Utility functions for working with binary data.
  # Author: rbuckheit
  #

  # hex
  # ===

  HEX_CHARS_PER_BYTE = 2
  HEX_SIZE_PER_CHAR  = 16

  hexToUint = (hex) ->
    unless _.isString(hex)
      throw new Erorr 'argument is not a string'

    bytes = []
    for index in [0...hex.length] by HEX_CHARS_PER_BYTE
      hexByte = hex.substr(index, HEX_CHARS_PER_BYTE)
      bytes.push(parseInt(hexByte, HEX_SIZE_PER_CHAR))
    return new Uint8Array(bytes)

  # uint8
  # =====

  uint8ToString = (arr) ->
    unless arr instanceof Uint8Array
      log.error('illegal type', arr.constructor.name)
      throw new Error 'argument is not a uint8 array'

    chars = []
    [0...arr.length].forEach((index) ->
      val = arr[index]
      chars.push(String.fromCharCode(arr[index]))
    )
    return chars.join(EMPTY_STRING)

  UINT8_REPRESENTABLE_SIZE = 256

  getCharCodeUint8 = (c) ->
    code = c.charCodeAt()

    if code >= UINT8_REPRESENTABLE_SIZE
      throw new Error 'code outside of range!'
    else
      return code

  stringToUint8 = (string) ->
    unless _.isString(string)
      throw new Error 'argument is not a string'
    return new Uint8Array(_.map(string, getCharCodeUint8))

  return {
    hexToUint
    uint8ToString
    stringToUint8
  }

