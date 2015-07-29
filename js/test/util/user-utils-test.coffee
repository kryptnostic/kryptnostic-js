define [
  'require'
  'kryptnostic.user-utils'
], (require) ->

  UserUtils = require 'kryptnostic.user-utils'

  { componentsToPrincipal, principalToComponents } = UserUtils

  describe 'UserUtils', ->

    describe '#principalToComponents', ->

      it 'should split into realm and username', ->
        expect(principalToComponents('krypt|ryan')).toEqual({ username: 'ryan', realm: 'krypt' })
      it 'should throw if too many components', ->
        expect(-> principalToComponents('krypt|ryan|test')).toThrow()
      it 'should throw if invalid string', ->
        expect(-> principalToComponents('krypt')).toThrow()
      it 'should throw on falsy username', ->
        expect(-> principalToComponents('krypt|')).toThrow()
      it 'should throw on falsy realm', ->
        expect(-> principalToComponents('|user')).toThrow()

    describe '#componentsToPrincipal', ->

      it 'should throw if username missing', ->
        expect(-> componentsToPrincipal({ realm: 'krypt' })).toThrow()
      it 'should throw if realm missing', ->
        expect(-> componentsToPrincipal({ username: 'ryan' })).toThrow()
      it 'should join into string format', ->
        expect(componentsToPrincipal({ username: 'ryan', realm: 'krypt' })).toBe('krypt|ryan')


