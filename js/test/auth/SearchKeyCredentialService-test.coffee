define [
  'require'
  'kryptnostic.search-key-credential-service'
  'kryptnostic.mock.kryptnostic-engine'
], (require) ->

  SearchKeyCredentialService = require 'kryptnostic.search-key-credential-service'
  MockKryptnosticEngine      = require 'kryptnostic.mock.kryptnostic-engine'

  # mock data
  # =========

  PASSWORD = 'demo'

  DEMO_BLOCK_CIPHERTEXT = {
    iv       : 'ewcVcNXbhKK463r41DFS2g==',
    salt     : 'X0jjTehInQbl5KPK0sj/J9qgu9M=',
    contents : '6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac='
  }

  DEMO_DECRYPTED = '¢búð)lÚèKwz\'öOXfþP¦ã¾þlTíMY'

  # tests
  # =====

  describe 'SearchKeyCredentialService', ->

    { service }  = {}

    beforeEach ->
      kryptnosticEngine = new MockKryptnosticEngine()
      service           = new SearchKeyCredentialService()
      _.extend(service, { kryptnosticEngine })

    afterEach ->
      service.cryptoKeyStorageApi.getFhePrivateKey.restore()

    describe '#getFheSearchKey', ->

      it 'should initialize and store a key if it does not exist', (done) ->
        { storedBlockCiphertext } = {}

        sinon.stub(service.cryptoKeyStorageApi, 'getFhePrivateKey').returns(undefined)
        sinon.stub(service.cryptoKeyStorageApi, 'setFhePrivateKey', (blockCiphertext) ->
          storedBlockCiphertext = blockCiphertext
          return Promise.resolve()
        )
        service.getFheSearchKey({ password : PASSWORD })
        .then (keyString) ->
          expect(keyString).toBe('fhe.pvt')
          expect(storedBlockCiphertext).toBeDefined()
          expect(storedBlockCiphertext.constructor.name).toBe('BlockCiphertext')
          done()

      it 'should load a key if it exists', (done) ->
        sinon.stub(service.cryptoKeyStorageApi, 'getFhePrivateKey').returns(DEMO_BLOCK_CIPHERTEXT)
        service.getFheSearchKey({ password : PASSWORD })
        .then (keyString) ->
          expect(keyString).toBe(DEMO_DECRYPTED)
          done()
