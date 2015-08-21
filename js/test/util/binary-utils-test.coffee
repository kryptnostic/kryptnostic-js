define [
  'require'
  'kryptnostic.binary-utils'
], (require) ->

  BinaryUtils = require 'kryptnostic.binary-utils'

  describe 'BinaryUtils', ->

    STRING_HEX = '012344567890abcde'
    UINT8_HEX  = new Uint8Array [1, 35, 68, 86, 120, 144, 171, 205, 14]

    STRING_123      = '123'
    UINT8_CODES_123 = new Uint8Array [49, 50, 51]

    # hex
    # ===

    describe 'hexToUint', ->

      it 'should convert a known value', ->
        expect(BinaryUtils.hexToUint(STRING_HEX)).toEqual(UINT8_HEX)

      it 'should throw if not string', ->
        expect( -> BinaryUtils.hexToUint(123) ).toThrow()

    describe 'stringToHex', ->

      it 'should convert a known value', ->
        expect(BinaryUtils.stringToHex('abcxyz')).toBe('61626378797a')

      it 'should throw if not string', ->
        expect( -> BinaryUtils.stringToHex(123) ).toThrow()

    # uint8
    # =====

    describe 'uint8ToString', ->

      it 'should convert a known value', ->
        expect(BinaryUtils.uint8ToString(UINT8_CODES_123)).toBe(STRING_123)

      it 'should throw if not a uint8 array', ->
        expect( -> BinaryUtils.uint8ToString(new Uint16Array()) ).toThrow()

    describe 'stringToUint8', ->

      it 'should throw on unrepresentable characters with codes above 256 inclusive', ->
        boundaryExcChar = String.fromCharCode(256)
        boundaryIncChar = String.fromCharCode(255)
        expect( -> BinaryUtils.stringToUint8(boundaryExcChar) ).toThrow()
        expect( -> BinaryUtils.stringToUint8(boundaryIncChar) ).not.toThrow()

      it 'should convert a known value', ->
        expect(BinaryUtils.stringToUint8(STRING_123)).toEqual(UINT8_CODES_123)
