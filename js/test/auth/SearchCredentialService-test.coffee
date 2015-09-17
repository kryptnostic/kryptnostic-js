define [
  'require'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.binary-utils'
  'kryptnostic.search-credential-service'
  'kryptnostic.mock.search-key-generator'
], (require) ->

  Logger                  = require 'kryptnostic.logger'
  Forge                   = require 'forge'
  BinaryUtils             = require 'kryptnostic.binary-utils'
  SearchCredentialService = require 'kryptnostic.search-credential-service'
  MockSearchKeyGenerator  = require 'kryptnostic.mock.search-key-generator'

  log = Logger.get('SearchCredentialService-test')

  # mock data
  # =========

  DEMO_PLAINTEXT = 'foo foo foo'
  DEMO_CIPHERTEXT_BASE64 =
    'kUolqTlsUr0EwGmjRR099EANNkR6ZQdRTugBhcYu2jYjYfrJ7F0imAKcELKidw+VUZeb6vKJsO0rLFwly54Duw=='
  DEMO_CIPHERTEXT =
    [ DEMO_CIPHERTEXT_BASE64 ]

  #
  # if you need to generate a new mock key, use:
  # openssl genrsa -des3 -out private.pem 4096
  # openssl rsa -in private.pem -out private_unencrypted.pem -outform PEM
  #

  MOCK_PEM_RSA_PRIVATE_KEY = '-----BEGIN RSA PRIVATE KEY-----\
    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\
    -----END RSA PRIVATE KEY-----'

  # coffeelint: disable=spacing_after_comma
  # coffeelint: disable=max_line_length
  ENCRYPTED_STORED_UINT8_KEY = new Uint8Array([
    131,0,87,0,214,0,40,0,173,0,202,0,52,0,145,0,234,0,149,0,73,0,48,0,106,0,3,0,166,0,48,0,85,0,205,0,88,0,118,0,198,0,211,0,119,0,175,0,83,0,250,0,18,0,200,0,87,0,104,0,186,0,88,0,72,0,8,0,224,0,149,0,198,0,21,0,157,0,170,0,82,0,36,0,44,0,100,0,184,0,135,0,169,0,204,0,16,0,139,0,134,0,57,0,250,0,192,0,102,0,180,0,4,0,7,0,76,0,203,0,39,0,105,0,9,0,179,0,240,0,213,0,81,0,124,0,255,0,164,0,196,0,247,0,61,0,184,0,138,0,109,0,202,0,233,0,133,0,105,0,193,0,148,0,67,0,117,0,66,0,219,0,182,0,154,0,127,0,215,0,212,0,123,0,111,0,239,0,226,0,17,0,133,0,135,0,151,0,193,0,7,0,162,0,22,0,58,0,227,0,227,0,21,0,63,0,114,0,236,0,151,0,120,0,90,0,229,0,147,0,155,0,59,0,65,0,5,0,174,0,203,0,212,0,119,0,126,0,180,0,62,0,135,0,121,0,68,0,210,0,64,0,177,0,212,0,30,0,24,0,221,0,13,0,104,0,235,0,93,0,107,0,110,0,239,0,109,0,12,0,36,0,231,0,53,0,243,0,18,0,58,0,167,0,237,0,252,0,16,0,72,0,112,0,215,0,87,0,217,0,18,0,116,0,166,0,165,0,254,0,2,0,177,0,236,0,117,0,149,0,34,0,93,0,159,0,126,0,3,0,137,0,19,0,55,0,16,0,126,0,102,0,37,0,253,0,127,0,164,0,103,0,123,0,190,0,176,0,134,0,221,0,12,0,143,0,238,0,109,0,29,0,235,0,190,0,92,0,24,0,15,0,192,0,44,0,48,0,77,0,226,0,43,0,186,0,22,0,193,0,140,0,33,0,4,0,15,0,226,0,50,0,245,0,95,0,190,0,141,0,54,0,108,0,43,0,29,0,73,0,231,0,39,0,71,0,14,0,27,0,110,0,44,0,33,0,15,0,58,0,148,0,231,0,59,0,8,0,109,0,71,0,159,0,32,0,189,0,219,0,31,0,86,0,249,0,10,0,167,0,107,0,180,0,35,0,174,0,36,0,68,0,194,0,118,0,95,0,19,0,13,0,38,0,246,0,252,0,249,0,215,0,39,0,43,0,254,0,3,0,129,0,104,0,118,0,191,0,254,0,141,0,226,0,87,0,238,0,152,0,68,0,88,0,30,0,20,0,152,0,236,0,27,0,139,0,54,0,165,0,40,0,107,0,55,0,143,0,35,0,156,0,141,0,191,0,140,0,23,0,82,0,8,0,156,0,10,0,133,0,89,0,209,0,172,0,243,0,129,0,66,0,192,0,224,0,201,0,152,0,33,0,122,0,192,0,217,0,76,0,107,0,56,0,253,0,223,0,151,0,166,0,164,0,141,0,73,0,158,0,142,0,72,0,121,0,202,0,210,0,112,0,141,0,244,0,151,0,32,0,99,0,178,0,234,0,92,0,228,0,54,0,133,0,71,0,178,0,133,0,6,0,199,0,153,0,211,0,100,0,201,0,164,0,14,0,158,0,134,0,229,0,228,0,31,0,73,0,177,0,212,0,3,0,10,0,16,0,62,0,76,0,3,0,76,0,229,0,199,0,233,0,69,0,161,0,99,0,117,0,72,0,21,0,211,0,203,0,36,0,46,0,230,0,172,0,35,0,11,0,73,0,165,0,43,0,241,0,190,0,8,0,73,0,31,0,188,0,245,0,79,0,221,0,125,0,37,0,237,0,245,0,189,0,102,0,222,0,24,0,15,0,178,0,120,0,126,0,81,0,213,0,19,0,117,0,116,0,115,0,95,0,64,0,18,0,61,0,121,0,229,0,55,0,87,0,148,0,37,0,10,0,203,0,14,0,205,0,100,0,28,0,207,0,195,0,192,0,172,0,195,0,201,0,89,0,167,0,238,0,99,0,240,0,69,0,57,0,53,0,62,0,68,0,154,0,26,0,195,0,92,0,73,0,113,0,102,0,11,0,141,0,78,0,17,0,25,0,143,0,211,0,72,0,150,0,115,0,134,0,29,0,247,0,233,0,175,0,123,0,192,0,164,0,198,0,190,0,129,0,199,0,138,0,135,0,180,0,22,0,27,0,0,0,202,0,86,0,236,0,189,0,169,0,98,0,75,0,133,0,55,0,155,0,45,0,125,0,93,0,87,0,232,0,218,0,66,0,21,0,85,0,239,0,7,0,214,0,250,0,100,0,238,0
  ])
  UNENCRYPTED_STORED_UINT8_KEY = new Uint8Array([
    131,0,87,0,214,0,40,0,173,0,202,0,52,0,145,0,234,0,149,0,73,0,48,0,106,0,3,0,166,0,48,0,85,0,205,0,88,0,118,0,198,0,211,0,119,0,175,0,83,0,250,0,18,0,200,0,87,0,104,0,186,0,88,0,72,0,8,0,224,0,149,0,198,0,21,0,157,0,170,0,82,0,36,0,44,0,100,0,184,0,135,0,169,0,204,0,16,0,139,0,134,0,57,0,250,0,192,0,102,0,180,0,4,0,7,0,76,0,203,0,39,0,105,0,9,0,179,0,240,0,213,0,81,0,124,0,255,0,164,0,196,0,247,0,61,0,184,0,138,0,109,0,202,0,233,0,133,0,105,0,193,0,148,0,67,0,117,0,66,0,219,0,182,0,154,0,127,0,215,0,212,0,123,0,111,0,239,0,226,0,17,0,133,0,135,0,151,0,193,0,7,0,162,0,22,0,58,0,227,0,227,0,21,0,63,0,114,0,236,0,151,0,120,0,90,0,229,0,147,0,155,0,59,0,65,0,5,0,174,0,203,0,212,0,119,0,126,0,180,0,62,0,135,0,121,0,68,0,210,0,64,0,177,0,212,0,30,0,24,0,221,0,13,0,104,0,235,0,93,0,107,0,110,0,239,0,109,0,12,0,36,0,231,0,53,0,243,0,18,0,58,0,167,0,237,0,252,0,16,0,72,0,112,0,215,0,87,0,217,0,18,0,116,0,166,0,165,0,254,0,2,0,177,0,236,0,117,0,149,0,34,0,93,0,159,0,126,0,3,0,137,0,19,0,55,0,16,0,126,0,102,0,37,0,253,0,127,0,164,0,103,0,123,0,190,0,176,0,134,0,221,0,12,0,143,0,238,0,109,0,29,0,235,0,190,0,92,0,24,0,15,0,192,0,44,0,48,0,77,0,226,0,43,0,186,0,22,0,193,0,140,0,33,0,4,0,15,0,226,0,50,0,245,0,95,0,190,0,141,0,54,0,108,0,43,0,29,0,73,0,231,0,39,0,71,0,14,0,27,0,110,0,44,0,33,0,15,0,58,0,148,0,231,0,59,0,8,0,109,0,71,0,159,0,32,0,189,0,219,0,31,0,86,0,249,0,10,0,167,0,107,0,180,0,35,0,174,0,36,0,68,0,194,0,118,0,95,0,19,0,13,0,38,0,246,0,252,0,249,0,215,0,39,0,43,0,254,0,3,0,129,0,104,0,118,0,191,0,254,0,141,0,226,0,87,0,238,0,152,0,68,0,88,0,30,0,20,0,152,0,236,0,27,0,139,0,54,0,165,0,40,0,107,0,55,0,143,0,35,0,156,0,141,0,191,0,140,0,23,0,82,0,8,0,156,0,10,0,133,0,89,0,209,0,172,0,243,0,129,0,66,0,192,0,224,0,201,0,152,0,33,0,122,0,192,0,217,0,76,0,107,0,56,0,253,0,223,0,151,0,166,0,164,0,141,0,73,0,158,0,142,0,72,0,121,0,202,0,210,0,112,0,141,0,244,0,151,0,32,0,99,0,178,0,234,0,92,0,228,0,54,0,133,0,71,0,178,0,133,0,6,0,199,0,153,0,211,0,100,0,201,0,164,0,14,0,158,0,134,0,229,0,228,0,31,0,73,0,177,0,212,0,3,0,10,0,16,0,62,0,76,0,3,0,76,0,229,0,199,0,233,0,69,0,161,0,99,0,117,0,72,0,21,0,211,0,203,0,36,0,46,0,230,0,172,0,35,0,11,0,73,0,165,0,43,0,241,0,190,0,8,0,73,0,31,0,188,0,245,0,79,0,221,0,125,0,37,0,237,0,245,0,189,0,102,0,222,0,24,0,15,0,178,0,120,0,126,0,81,0,213,0,19,0,117,0,116,0,115,0,95,0,64,0,18,0,61,0,121,0,229,0,55,0,87,0,148,0,37,0,10,0,203,0,14,0,205,0,100,0,28,0,207,0,195,0,192,0,172,0,195,0,201,0,89,0,167,0,238,0,99,0,240,0,69,0,57,0,53,0,62,0,68,0,154,0,26,0,195,0,92,0,73,0,113,0,102,0,11,0,141,0,78,0,17,0,25,0,143,0,211,0,72,0,150,0,115,0,134,0,29,0,247,0,233,0,175,0,123,0,192,0,164,0,198,0,190,0,129,0,199,0,138,0,135,0,180,0,22,0,27,0,0,0,202,0,86,0,236,0,189,0,169,0,98,0,75,0,133,0,55,0,155,0,45,0,125,0,93,0,87,0,232,0,218,0,66,0,21,0,85,0,239,0,7,0,214,0,250,0,100,0,238,0
  ])
  # coffeelint: enable=max_line_length
  # coffeelint: enable=spacing_after_comma

  # tests
  # =====

  describe 'SearchCredentialService', ->

    { service }  = {}

    beforeEach ->
      privateKey = Forge.pki.privateKeyFromPem(MOCK_PEM_RSA_PRIVATE_KEY)
      publicKey  = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)
      keypair    = { privateKey, publicKey }

      searchKeyGenerator = new MockSearchKeyGenerator()
      service            = new SearchCredentialService()

      # { searchKeySerializer } = service

      sinon.stub(service.credentialLoader, 'getCredentials').returns({ keypair })
      # sinon.stub(searchKeySerializer.credentialLoader, 'getCredentials').returns({ keypair })
      _.extend(service, { searchKeyGenerator })

    afterEach ->
      service.credentialLoader.getCredentials.restore()
      # service.searchKeySerializer.credentialLoader.getCredentials.restore()
      unmockServerKeys()

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

          expect(fhePrivateKey).toEqual(BinaryUtils.stringToUint8('fhe.priv'),
            'fhePrivateKey did not match')
          expect(searchPrivateKey).toEqual(BinaryUtils.stringToUint8('search.pvt'),
            'searchPrivateKey did not match')
          expect(clientHashFunction).toEqual(BinaryUtils.stringToUint8('hash.fun'),
            'clientHashFunction did not match')

          done()

      it 'should throw if keys are partially initalized', (done) ->
        mockServerKeys({
          fhePrivateKey      : ENCRYPTED_STORED_UINT8_KEY
          searchPrivateKey   : undefined
          clientHashFunction : undefined
        })

        service.getAllCredentials()
        .then (uint8key) ->
          throw new Error 'the preceeding call should have failed, but did not'
          done()
        .catch (e) ->
          log.warn('test failed as expected: ', { message: e.message })
          done()

      it 'should load and decrypt all keys if all keys exist', (done) ->
        mockServerKeys({
          fhePrivateKey      : ENCRYPTED_STORED_UINT8_KEY
          searchPrivateKey   : ENCRYPTED_STORED_UINT8_KEY
          clientHashFunction : UNENCRYPTED_STORED_UINT8_KEY
        })

        service.getAllCredentials()
        .then (allCredentials) ->
          fhePrivateKey      = allCredentials.FHE_PRIVATE_KEY
          searchPrivateKey   = allCredentials.SEARCH_PRIVATE_KEY
          clientHashFunction = allCredentials.CLIENT_HASH_FUNCTION

          expect(fhePrivateKey).toEqual(BinaryUtils.stringToUint8('fhe.priv')
            'fhePrivateKey did not match')
          expect(searchPrivateKey).toEqual(BinaryUtils.stringToUint8('fhe.priv')
            'searchPrivateKey did not match')
          expect(clientHashFunction).toEqual(UNENCRYPTED_STORED_UINT8_KEY
            'clientHashFunction did not match')

          done()
