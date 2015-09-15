define [
  'require'
  'sinon'
  'kryptnostic.caching-service'
  'kryptnostic.user-directory-api'
], (require) ->

  sinon            = require 'sinon'
  CachingService   = require 'kryptnostic.caching-service'
  UserDirectoryApi = require 'kryptnostic.user-directory-api'

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

  key4   = '1-2-3-4-5-6-7-8-9'
  MOCK_USER = {
    id   : '1-2-3-4-5-6-7-8-9'
    name : 'christopher wallace'
  }

  # setup
  # =====

  { userDirectory } = {}

  beforeEach ->
    userDirectory = new UserDirectoryApi()
    sinon.stub(userDirectory, 'getUser', (uuid) ->
      return Promise.resolve(_.cloneDeep( MOCK_USER ))
    )

  afterEach ->
    CachingService.destroy()

  describe 'CachingService', ->

    describe '#store', ->

      it 'should store an arbitrary object', ->
        CachingService.store( key, value )

    describe '#load', ->

      it 'should load a stored object', ->
        CachingService.store( key2, value2 )
        gotten = CachingService.get( key2 )

        expect(gotten.f).toBeDefined()
        expect(gotten.f).toBe('br')
        expect(gotten.b).toBeDefined()
        expect(gotten.b).toBe('bz')

      it 'should return falsey if the object is not present', ->
        expect( CachingService.get('82') ).toBeNull()

    # for the future
    #
    # describe '#loadWithCallback', ->
    #   it 'should fetch an object if not present', ->
    #     gotten = CachingService.getAndLoad( key4, userDirectory.getUser( key4 ) )
    #     expect( gotten ).toBe( MOCK_USER )
    #     expect( CachingService.get( key4 ) ).toBe( MOCK_USER )

    describe '#destroy', ->

      it 'should destroy all stored credentials', ->
        CachingService.store( key3, value3 )
        CachingService.destroy()

        expect( CachingService.get( key3 ) ).toBeNull()
