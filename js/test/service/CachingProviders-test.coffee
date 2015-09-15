define [
  'require'
  'kryptnostic.caching-provider.jscache'
  'kryptnostic.caching-provider.memory'
  'kryptnostic.caching-service'
], (require) ->

  JscacheCachingProvider        = require 'kryptnostic.caching-provider.jscache'
  InMemoryCachingProvider       = require 'kryptnostic.caching-provider.memory'
  CachingService                = require 'kryptnostic.caching-service'

  [
    JscacheCachingProvider
    InMemoryCachingProvider
  ].forEach ( CachingProvider ) ->

    key = '1234'
    value = {
      foo: 'bar',
      bang: 'baz'
    }

    key2 = '5678'
    value2 = {
      f: 'br',
      b: 'bz'
    }

    key3 = '910'
    value3 = {
      a: 'b',
      c: 'd'
    }

    beforeEach ->
      CachingProvider.destroy()

    afterEach ->
      CachingProvider.destroy()

    describe CachingProvider.constructor.name, ->

      describe '#store', ->

        it 'should store an arbitrary object', ->
          CachingProvider.store( CachingService.DEFAULT_GROUP, key, value )

      describe '#load', ->

        it 'should load all stored credentials', ->
          CachingProvider.store( CachingService.DEFAULT_GROUP, key2, value2 )
          gotten = CachingProvider.get( CachingService.DEFAULT_GROUP, key2 )

          expect(gotten.f).toBeDefined()
          expect(gotten.f).toBe('br')
          expect(gotten.b).toBeDefined()
          expect(gotten.b).toBe('bz')

        it 'should return falsey if the object is not present', ->
          expect( CachingProvider.get( CachingService.DEFAULT_GROUP, '82') ).toBeNull()

      describe '#destroy', ->

        it 'should destroy all stored credentials', ->
          CachingProvider.store( CachingService.DEFAULT_GROUP, key3, value3 )
          CachingProvider.destroy()

          expect( CachingProvider.get( CachingService.DEFAULT_GROUP, key3 ) ).toBeNull()
