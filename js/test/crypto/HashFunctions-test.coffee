
# original inputs
# ===============
INPUT             = 'gKq87ryelpzqYdpSR4TCOz31'

# hashed outputs
# ==============
INPUT_SHA_256     = 'THVpo2vnSWpvHKGDBEgynzEDgpaoMxp5t1WCREngZMQ='
INPUT_MURMUR3_128 = 'fded3b3d77977b7a2bd9441cdfdc3402'

# tests
# =====

define ['require', 'kryptnostic.hash-function'], (require) ->

  HashFunction = require 'kryptnostic.hash-function'

  describe 'HashFunction', ->

    describe 'SHA_256', ->

      it 'should return a known hash value', ->
        expect(HashFunction.SHA_256(INPUT)).toEqual(INPUT_SHA_256)

    describe 'MURMUR3_128', ->

      it 'should return a known hash value', ->
        expect(HashFunction.MURMUR3_128(INPUT)).toEqual(INPUT_MURMUR3_128)
