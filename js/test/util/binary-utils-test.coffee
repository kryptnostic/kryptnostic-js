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

    # uint
    # ====

    describe 'uint8ToString', ->

      it 'should convert a known value', ->
        expect(BinaryUtils.uint8ToString(UINT8_CODES_123)).toBe(STRING_123)

      it 'should throw if not a uint8 array', ->
        expect( -> BinaryUtils.uint8ToString('') ).toThrow()

    describe 'stringToUint8', ->

      it 'should throw on unrepresentable characters with codes above 256 inclusive', ->
        boundaryExcChar = String.fromCharCode(256)
        boundaryIncChar = String.fromCharCode(255)
        expect( -> BinaryUtils.stringToUint8(boundaryExcChar) ).toThrow()
        expect( -> BinaryUtils.stringToUint8(boundaryIncChar) ).not.toThrow()

      it 'should convert a known value', ->
        expect(BinaryUtils.stringToUint8(STRING_123)).toEqual(UINT8_CODES_123)

    describe 'stringToUint16', ->
      it 'should convert string to uint16', ->
        str = 'Ag©h'
        expect(BinaryUtils.stringToUint16(str)).toEqual(new Uint16Array([65, 103, 169, 104]))

    describe 'uint16ToString', ->
      it 'should convert uint16 to string', ->
        uint = new Uint16Array([65, 103, 169, 104])
        str = 'Ag©h'
        expect(BinaryUtils.uint16ToString(uint)).toEqual(str)

    describe 'uint8/string integration', ->

      it 'should convert uint8 -> string -> uint8', ->
        string = BinaryUtils.uint8ToString(UINT8_CODES_123)
        uint8  = BinaryUtils.stringToUint8(string)
        expect(uint8).toEqual(UINT8_CODES_123)

      it 'should convert string -> uint8 -> string', ->
        uint8  = BinaryUtils.stringToUint8(STRING_123)
        string = BinaryUtils.uint8ToString(uint8)
        expect(string).toEqual(STRING_123)

    uint1  = new Uint8Array([1, 2, 3])
    uint2  = new Uint8Array([4, 5, 6])
    uint3  = new Uint8Array([7, 8, 9])
    flat   = new Uint8Array([1, 2, 3, 4, 5, 6, 7, 8, 9])

    describe 'joinUint', ->

      it 'should flatten uint arrays', ->
        nested = [ uint1, uint2, uint3 ]
        expect(BinaryUtils.joinUint(nested)).toEqual(flat)

    describe 'chunkUint', ->

      it 'should split uint array into chunks', ->
        chunkSize = 3
        expect(BinaryUtils.chunkUint(flat, chunkSize)).toEqual([ uint1, uint2, uint3 ])

    describe 'uint8ToUint16', ->

      it 'should copy binary data', ->
        expect(BinaryUtils.uint8ToUint16(new Uint8Array([255, 255])))
          .toEqual(new Uint16Array([65535]))

    describe 'uint16ToUint8', ->

      it 'should copy binary data', ->
        expect(BinaryUtils.uint16ToUint8(new Uint16Array([65535])))
          .toEqual(new Uint8Array([255, 255]))
