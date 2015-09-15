define [
  'require'
  'sinon'
  'kryptnostic.caching-service'
], (require) ->

  sinon            = require 'sinon'
  CachingService   = require 'kryptnostic.caching-service'

  key   = 'testKey'
  value = {
    foo: 'bar',
    bang: 'baz'
  }

  key2   = 'testKey2'
  value2 = {
    f: 'br',
    b: 'bz'
  }

  key3   = 'testKey3'
  value3 = {
    a: 'b',
    c: 'd'
  }

  # setup
  # =====

  afterEach ->
    CachingService.destroy()

  describe 'CachingService', ->

    describe '#load', ->

      it 'should load a stored object', ->
        CachingService.store( CachingService.DEFAULT_GROUP, key2, value2 )
        gotten = CachingService.get( CachingService.DEFAULT_GROUP, key2 )

        expect( gotten.f ).toBeDefined()
        expect( gotten.f ).toBe('br')
        expect( gotten.b ).toBeDefined()
        expect( gotten.b ).toBe('bz')

      it 'should return null if the object is not present', ->
        expect( CachingService.get( CachingService.DEFAULT_GROUP, '82') ).toBeNull()

    # for the future
    #
    # describe '#loadWithCallback', ->
    #   it 'should fetch an object if not present', ->
    #     gotten = CachingService.getAndLoad( key4, userDirectory.getUser( key4 ) )
    #     expect( gotten ).toBe( MOCK_USER )
    #     expect( CachingService.get( key4 ) ).toBe( MOCK_USER )

    describe '#destroy', ->

      it 'should destroy all stored credentials', ->
        CachingService.store( CachingService.DEFAULT_GROUP, key3, value3 )
        CachingService.destroy()

        expect( CachingService.get( CachingService.DEFAULT_GROUP, key3 ) ).toBeNull()
