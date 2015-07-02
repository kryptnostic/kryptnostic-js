# mock data
# =========

TEST_CONTENTS = 'gKq87ryelpzqYdpSR4TCOz31'
TEST_SHA_256  = 'THVpo2vnSWpvHKGDBEgynzEDgpaoMxp5t1WCREngZMQ='

# tests
# =====

define ['require', 'soteria.hash-function'], (require) ->

  HashFunction = require 'soteria.hash-function'

  describe 'HashFunction', ->

    describe 'SHA_256', ->

      it 'should return a known hash value', ->
        expect(HashFunction.SHA_256(TEST_CONTENTS)).toEqual(TEST_SHA_256)
