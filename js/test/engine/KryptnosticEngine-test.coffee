define [
  'require'
  'kryptnostic.kryptnostic-engine'
  'kryptnostic.logger'
  'kryptnostic.mock.mock-data-utils'
], (require) ->

  # kryptnostic classes
  KryptnosticEngine = require 'kryptnostic.kryptnostic-engine'

  # utils
  Logger        = require 'kryptnostic.logger'
  MockDataUtils = require 'kryptnostic.mock.mock-data-utils'

  # mock data
  MOCK_INDEX_TOKEN        = MockDataUtils.generateMockIndexTokenAsUint8()
  MOCK_FHE_PRIVATE_KEY    = MockDataUtils.generateMockFhePrivateKeyAsUint8()
  MOCK_SEARCH_PRIVATE_KEY = MockDataUtils.generateMockSearchPrivateKeyAsUint8()

  log = Logger.get('KryptnosticEngine-test')

  #
  # tests
  #
  describe 'KryptnosticEngine :', ->

    beforeEach ->
      jasmine.addMatchers toBeUint8ArrayOfSize: ->
        {
          compare: (value, expectedSize) ->

            objectType    = Object.prototype.toString.call(value)
            isUint8Array  = objectType is '[object Uint8Array]'
            isCorrectSize = value.length? and value.length is expectedSize

            result =
              pass    : isUint8Array and isCorrectSize
              message : undefined

            if !result.pass
              if !isUint8Array and !isCorrectSize
                result.message =
                  'expected an Uint8Array of size ' + expectedSize +
                  ', but got ' + objectType + ' of size ' + value.length
              else if !isUint8Array
                result.message =
                  'expected an Uint8Array, but got ' + objectType
              else if !isCorrectSize
                result.message =
                  'expected an Uint8Array of size ' + expectedSize +
                  ', but got size ' + value.length
              else
                result.message =
                  'expected an Uint8Array of size ' + expectedSize +
                  ', but got ' + value

            return result
        }

    it 'requires Module.KryptnosticClient to be defined', ->

      expect(Module).toBeDefined()
      expect(Module.KryptnosticClient).toBeDefined()

    it 'should generate a proper private key, Uint8Array of length 329760', ->

      engine1 = new KryptnosticEngine()
      engine2 = new KryptnosticEngine({
        fhePrivateKey    : MOCK_FHE_PRIVATE_KEY
        searchPrivateKey : MOCK_SEARCH_PRIVATE_KEY
      })

      fhePrivateKey1 = engine1.getPrivateKey()
      expect(fhePrivateKey1).toBeUint8ArrayOfSize(MockDataUtils.FHE_PRIVATE_KEY_SIZE)

      fhePrivateKey2 = engine2.getPrivateKey()
      expect(fhePrivateKey2).toBeUint8ArrayOfSize(MockDataUtils.FHE_PRIVATE_KEY_SIZE)

    it 'should generate a proper private search key, Uint8Array of length 4096', ->

      engine1 = new KryptnosticEngine()
      engine2 = new KryptnosticEngine({
        fhePrivateKey    : MOCK_FHE_PRIVATE_KEY
        searchPrivateKey : MOCK_SEARCH_PRIVATE_KEY
      })

      searchPrivateKey1 = engine1.getSearchPrivateKey()
      expect(searchPrivateKey1).toBeUint8ArrayOfSize(MockDataUtils.SEARCH_PRIVATE_KEY_SIZE)

      searchPrivateKey2 = engine2.getSearchPrivateKey()
      expect(searchPrivateKey2).toBeUint8ArrayOfSize(MockDataUtils.SEARCH_PRIVATE_KEY_SIZE)

    it 'should generate a proper client hash function, Uint8Array of length 1060896', ->

      engine1 = new KryptnosticEngine()
      engine2 = new KryptnosticEngine({
        fhePrivateKey    : MOCK_FHE_PRIVATE_KEY
        searchPrivateKey : MOCK_SEARCH_PRIVATE_KEY
      })

      clientHashFn1 = engine1.calculateClientHashFunction()
      expect(clientHashFn1).toBeUint8ArrayOfSize(MockDataUtils.CLIENT_HASH_FUNCTION_SIZE)

      clientHashFn2 = engine2.calculateClientHashFunction()
      expect(clientHashFn2).toBeUint8ArrayOfSize(MockDataUtils.CLIENT_HASH_FUNCTION_SIZE)

    it 'should generate a proper object index pair, Uint8Array of length 2064', ->

      engine1 = new KryptnosticEngine()
      engine2 = new KryptnosticEngine({
        fhePrivateKey    : MOCK_FHE_PRIVATE_KEY
        searchPrivateKey : MOCK_SEARCH_PRIVATE_KEY
      })

      objIndexPair1 = engine1.generateObjectIndexPair()
      expect(objIndexPair1).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_INDEX_PAIR_SIZE)

      objIndexPair2 = engine2.generateObjectIndexPair()
      expect(objIndexPair2).toBeUint8ArrayOfSize(MockDataUtils.OBJECT_INDEX_PAIR_SIZE)

    describe 'calculations should be consistent :', ->

      _engine1        = undefined
      _engine2        = undefined
      _objIndexPair1  = undefined
      _objIndexPair2  = undefined
      _objSearchPair1 = undefined
      _objSearchPair2 = undefined
      _objSharePair1  = undefined
      _objSharePair2  = undefined

      beforeAll ->

        # a new KryptnosticEngine will generate the private keys on initialization if they are not
        # passed into the constructor
        _engine1 = new KryptnosticEngine()

        # we use .slice() because we want to initialize KryptnosticEngine with a fresh copy of
        # the two keys to avoid potential bugs due to shared memory
        _engine2 = new KryptnosticEngine({
          fhePrivateKey    : _engine1.getPrivateKey().slice()
          searchPrivateKey : _engine1.getSearchPrivateKey().slice()
        })

      it 'should calculate the same private key', ->

        fhePrivateKey1 = _engine1.getPrivateKey()
        fhePrivateKey2 = _engine2.getPrivateKey()

        expect(fhePrivateKey1).toEqual(fhePrivateKey2)

      it 'should calculate the same search private key', ->

        searchPrivateKey1 = _engine1.getSearchPrivateKey()
        searchPrivateKey2 = _engine2.getSearchPrivateKey()

        expect(searchPrivateKey1).toEqual(searchPrivateKey2)

      it 'should calculate the same client hash function', ->

        clientHashFunction1 = _engine1.calculateClientHashFunction()
        clientHashFunction2 = _engine2.calculateClientHashFunction()

        expect(clientHashFunction1).toEqual(clientHashFunction2)

      it 'should calculate the same metadata address', ->

        objIndexPair1     = _engine1.generateObjectIndexPair()
        metatdataAddress1 = _engine1.calculateMetadataAddress(objIndexPair1, MOCK_INDEX_TOKEN)
        metatdataAddress2 = _engine2.calculateMetadataAddress(objIndexPair1, MOCK_INDEX_TOKEN)

        expect(metatdataAddress1).toEqual(metatdataAddress2)

        objIndexPair2     = _engine2.generateObjectIndexPair()
        metatdataAddress3 = _engine1.calculateMetadataAddress(objIndexPair2, MOCK_INDEX_TOKEN)
        metatdataAddress4 = _engine2.calculateMetadataAddress(objIndexPair2, MOCK_INDEX_TOKEN)

        expect(metatdataAddress3).toEqual(metatdataAddress4)

      it 'should calculate a different index pair every time', ->

        _objIndexPair1 = _engine1.generateObjectIndexPair()
        _objIndexPair2 = _engine2.generateObjectIndexPair()

        expect(_objIndexPair1).not.toEqual(_objIndexPair2)

      it 'should calculate different search pairs from the index pairs', ->

        _objSearchPair1 = _engine1.calculateObjectSearchPairFromObjectIndexPair(_objIndexPair1)
        _objSearchPair2 = _engine2.calculateObjectSearchPairFromObjectIndexPair(_objIndexPair2)

        expect(_objSearchPair1).not.toEqual(_objSearchPair2)

      it 'should calculate different share pairs from the search pairs', ->

        _objSharePair1  = _engine1.calculateObjectSharePairFromObjectSearchPair(_objSearchPair1)
        _objSharePair2  = _engine2.calculateObjectSharePairFromObjectSearchPair(_objSearchPair2)

        expect(_objSharePair1).not.toEqual(_objSharePair2)

      it 'should calculate different search pairs from the share pairs', ->

        objSearchPair1 = _engine1.calculateObjectSearchPairFromObjectSharePair(_objSharePair1)
        objSearchPair2 = _engine2.calculateObjectSearchPairFromObjectSharePair(_objSharePair2)

        expect(objSearchPair1).not.toEqual(objSearchPair2)
