define [
  'require'
  'forge'
  'kryptnostic.salt-generator'
], (require) ->

  SaltGenerator = require 'kryptnostic.salt-generator'
  Forge         = require 'forge'

  countBytes = (data) ->
    Forge.util.createBuffer(data, 'raw').length()

  describe 'SaltGenerator', ->

    describe '#generateSalt', ->

      it 'should produce distinct values', ->
        salt1 = SaltGenerator.generateSalt(8)
        salt2 = SaltGenerator.generateSalt(8)
        expect(salt1).not.toBe(salt2)

      it 'should produce values of the desired byte count', ->
        salt8  = SaltGenerator.generateSalt(8)
        salt32 = SaltGenerator.generateSalt(32)

        expect(countBytes(salt8)).toBe(8)
        expect(countBytes(salt32)).toBe(32)


