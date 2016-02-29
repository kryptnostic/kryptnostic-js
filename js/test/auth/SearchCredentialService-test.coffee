define [
  'require'
  'sinon'
  'kryptnostic.aes-crypto-service'
  'kryptnostic.cypher'
  'kryptnostic.logger'
  'kryptnostic.mock.mock-data-utils'
  'kryptnostic.search-credential-service'
], (require) ->

  # libraries
  sinon                   = require 'sinon'

  # kryptnostic
  AesCryptoService        = require 'kryptnostic.aes-crypto-service'
  Cypher                  = require 'kryptnostic.cypher'
  MockDataUtils           = require 'kryptnostic.mock.mock-data-utils'
  SearchCredentialService = require 'kryptnostic.search-credential-service'

  # utils
  Logger                  = require 'kryptnostic.logger'

  log = Logger.get('SearchCredentialService-test')

  # mock data
  # =========

  MOCK_FHE_PRIVATE_KEY_OCS          = new AesCryptoService(Cypher.AES_GCM_128)
  MOCK_SEARCH_PRIVATE_KEY_OCS       = new AesCryptoService(Cypher.AES_GCM_128)

  MOCK_FHE_PRIVATE_KEY              = MockDataUtils.generateMockFhePrivateKeyAsUint8()
  MOCK_SEARCH_PRIVATE_KEY           = MockDataUtils.generateMockSearchPrivateKeyAsUint8()
  MOCK_CLIENT_HASH_FUNCTION         = MockDataUtils.generateMockClientHashFunctionAsUint8()

  MOCK_ENCRYPTED_FHE_PRIVATE_KEY = MockDataUtils.generateMockBlockCipherText(
    MOCK_FHE_PRIVATE_KEY,
    MOCK_FHE_PRIVATE_KEY_OCS.key
  )

  MOCK_ENCRYPTED_SEARCH_PRIVATE_KEY = MockDataUtils.generateMockBlockCipherText(
    MOCK_SEARCH_PRIVATE_KEY,
    MOCK_SEARCH_PRIVATE_KEY_OCS.key
  )

  MOCK_CLIENT_SEARCH_KEYS = {
    fhePrivateKey      : MOCK_FHE_PRIVATE_KEY
    searchPrivateKey   : MOCK_SEARCH_PRIVATE_KEY
    clientHashFunction : MOCK_CLIENT_HASH_FUNCTION
  }

  # tests
  # =====

  describe 'SearchCredentialService', ->

    { service }  = {}

    beforeEach ->
      service = new SearchCredentialService()

      sinon.stub(service.searchKeyGenerator, 'generateClientKeys')
        .returns(MOCK_CLIENT_SEARCH_KEYS)

      sinon.stub(service.cryptoServiceLoader, 'getObjectCryptoService', (id) ->
        if id is 'KryptnosticEngine.PrivateKey'
          return Promise.resolve(MOCK_FHE_PRIVATE_KEY_OCS)
        else if id is 'KryptnosticEngine.SearchPrivateKey'
          return Promise.resolve(MOCK_SEARCH_PRIVATE_KEY_OCS)
        else
          return new AesCryptoService(Cypher.AES_GCM_128)
      )
      return

    afterEach ->
      unmockServerKeys()
      if service.searchKeyGenerator.generateClientKeys.restore?
        service.searchKeyGenerator.generateClientKeys.restore()
      if service.cryptoServiceLoader.getObjectCryptoService.restore?
        service.cryptoServiceLoader.getObjectCryptoService.restore()
      return

    mockServerKeys = ({ fhePrivateKey, searchPrivateKey, clientHashFunction }) ->
      sinon.stub(service.cryptoKeyStorageApi, 'getFhePrivateKey').returns(fhePrivateKey)
      sinon.stub(service.cryptoKeyStorageApi, 'getSearchPrivateKey').returns(searchPrivateKey)
      sinon.stub(service.cryptoKeyStorageApi, 'getClientHashFunction').returns(clientHashFunction)

    unmockServerKeys = ->
      if service.cryptoKeyStorageApi.getFhePrivateKey.restore?
        service.cryptoKeyStorageApi.getFhePrivateKey.restore()
      if service.cryptoKeyStorageApi.getSearchPrivateKey.restore?
        service.cryptoKeyStorageApi.getSearchPrivateKey.restore()
      if service.cryptoKeyStorageApi.getClientHashFunction.restore?
        service.cryptoKeyStorageApi.getClientHashFunction.restore()

    describe '#getAllCredentials', ->

      it 'should initialize and store all keys to server if they do not exist', (done) ->
        { storedFhe, storedSearch, storedClientHash } = {}

        mockServerKeys({
          fhePrivateKey      : undefined,
          searchPrivateKey   : undefined,
          clientHashFunction : undefined
        })

        sinon.stub(service.cryptoKeyStorageApi, 'setFhePrivateKey', (key) ->
          service.cryptoKeyStorageApi.getFhePrivateKey.restore()
          sinon.stub(service.cryptoKeyStorageApi, 'getFhePrivateKey').returns(key)
          return Promise.resolve()
        )
        sinon.stub(service.cryptoKeyStorageApi, 'setSearchPrivateKey', (key) ->
          service.cryptoKeyStorageApi.getSearchPrivateKey.restore()
          sinon.stub(service.cryptoKeyStorageApi, 'getSearchPrivateKey').returns(key)
          return Promise.resolve()
        )
        sinon.stub(service.cryptoKeyStorageApi, 'setClientHashFunction', (key) ->
          service.cryptoKeyStorageApi.getClientHashFunction.restore()
          sinon.stub(service.cryptoKeyStorageApi, 'getClientHashFunction').returns(key)
          return Promise.resolve()
        )

        service.getAllCredentials()
        .then (allCredentials) ->
          fhePrivateKey      = allCredentials.FHE_PRIVATE_KEY
          searchPrivateKey   = allCredentials.SEARCH_PRIVATE_KEY
          clientHashFunction = allCredentials.CLIENT_HASH_FUNCTION

          expect(fhePrivateKey).toEqual(
            MOCK_FHE_PRIVATE_KEY,
            'fhePrivateKey did not match'
          )

          expect(searchPrivateKey).toEqual(
            MOCK_SEARCH_PRIVATE_KEY,
            'searchPrivateKey did not match'
          )

          expect(clientHashFunction).toEqual(
            MOCK_CLIENT_HASH_FUNCTION,
            'clientHashFunction did not match'
          )

          done()

      it 'should throw an exception if keys are partially initialized', (done) ->

        mockServerKeys({
          fhePrivateKey      : MOCK_ENCRYPTED_FHE_PRIVATE_KEY
          searchPrivateKey   : undefined
          clientHashFunction : undefined
        })

        service.getAllCredentials()
        .then (uint8key) ->
          throw new Error 'getAllCredentials() should have failed, but did not'
          done()
        .catch (e) ->
          expect(e.message.indexOf('partially initialized') > -1).toEqual(true)
          log.warn('test failed as expected: ', { message: e.message })
          done()

      it 'should load and decrypt all keys if all keys exist', (done) ->

        # client hash function doesn't need to be encrypted
        mockServerKeys({
          fhePrivateKey      : MOCK_ENCRYPTED_FHE_PRIVATE_KEY
          searchPrivateKey   : MOCK_ENCRYPTED_SEARCH_PRIVATE_KEY
          clientHashFunction : MOCK_CLIENT_HASH_FUNCTION
        })

        service.getAllCredentials()
        .then (allCredentials) ->
          fhePrivateKey      = allCredentials.FHE_PRIVATE_KEY
          searchPrivateKey   = allCredentials.SEARCH_PRIVATE_KEY
          clientHashFunction = allCredentials.CLIENT_HASH_FUNCTION

          expect(fhePrivateKey).toEqual(
            MOCK_FHE_PRIVATE_KEY,
            'fhePrivateKey did not match'
          )

          expect(searchPrivateKey).toEqual(
            MOCK_SEARCH_PRIVATE_KEY,
            'searchPrivateKey did not match'
          )

          expect(clientHashFunction).toEqual(
            MOCK_CLIENT_HASH_FUNCTION,
            'clientHashFunction did not match'
          )

          done()
