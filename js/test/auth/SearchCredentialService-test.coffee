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
    200,0,54,0,113,0,96,0,121,0,171,0,143,0,125,0,44,0,78,0,188,0,50,0,170,0,184,0,9,0,237,0,154,0,100,0,79,0,3,0,98,0,207,0,232,0,163,0,230,0,29,0,215,0,147,0,1,0,226,0,15,0,63,0,163,0,209,0,189,0,205,0,226,0,107,0,208,0,168,0,173,0,159,0,175,0,207,0,87,0,175,0,45,0,209,0,18,0,91,0,175,0,96,0,240,0,199,0,209,0,255,0,168,0,16,0,75,0,31,0,125,0,216,0,77,0,105,0,128,0,76,0,98,0,19,0,154,0,145,0,14,0,49,0,122,0,219,0,189,0,41,0,253,0,20,0,242,0,199,0,214,0,135,0,16,0,156,0,139,0,177,0,94,0,12,0,161,0,51,0,90,0,59,0,132,0,183,0,9,0,206,0,234,0,119,0,32,0,13,0,83,0,87,0,43,0,184,0,171,0,58,0,34,0,2,0,4,0,226,0,224,0,81,0,143,0,63,0,158,0,229,0,214,0,172,0,252,0,83,0,88,0,43,0,64,0,218,0,241,0,182,0,200,0,88,0,101,0,78,0,19,0,79,0,18,0,180,0,98,0,229,0,127,0,250,0,90,0,133,0,102,0,27,0,105,0,131,0,48,0,130,0,63,0,203,0,197,0,32,0,211,0,220,0,153,0,66,0,94,0,164,0,31,0,140,0,217,0,154,0,15,0,117,0,5,0,85,0,11,0,66,0,215,0,69,0,15,0,213,0,189,0,62,0,42,0,228,0,130,0,119,0,185,0,204,0,117,0,163,0,205,0,66,0,14,0,209,0,171,0,9,0,66,0,101,0,2,0,170,0,57,0,11,0,242,0,23,0,177,0,5,0,109,0,173,0,228,0,170,0,10,0,72,0,227,0,178,0,142,0,217,0,87,0,195,0,104,0,110,0,77,0,213,0,56,0,129,0,114,0,255,0,124,0,181,0,185,0,141,0,45,0,103,0,242,0,0,0,65,0,250,0,199,0,47,0,165,0,135,0,176,0,214,0,163,0,21,0,243,0,111,0,179,0,199,0,5,0,112,0,243,0,79,0,137,0,179,0,124,0,197,0,221,0,11,0,79,0,118,0,131,0,74,0,65,0,80,0,75,0,237,0,241,0,157,0,46,0,13,0,103,0,142,0,230,0,177,0,141,0,247,0,25,0,13,0,131,0,60,0,123,0,77,0,206,0,187,0,100,0,200,0,222,0,55,0,92,0,186,0,160,0,221,0,49,0,112,0,85,0,125,0,92,0,180,0,36,0,4,0,247,0,67,0,147,0,228,0,142,0,99,0,110,0,226,0,235,0,73,0,164,0,105,0,89,0,6,0,3,0,226,0,28,0,191,0,181,0,164,0,71,0,226,0,71,0,236,0,123,0,224,0,204,0,67,0,146,0,14,0,212,0,100,0,25,0,151,0,161,0,12,0,255,0,128,0,212,0,49,0,200,0,243,0,253,0,162,0,109,0,122,0,198,0,78,0,224,0,62,0,196,0,251,0,140,0,102,0,54,0,79,0,255,0,107,0,177,0,229,0,48,0,242,0,101,0,35,0,103,0,192,0,185,0,183,0,60,0,194,0,9,0,37,0,163,0,18,0,94,0,235,0,105,0,156,0,208,0,103,0,7,0,163,0,9,0,30,0,116,0,49,0,85,0,195,0,238,0,152,0,94,0,173,0,9,0,77,0,215,0,146,0,84,0,74,0,0,0,112,0,148,0,59,0,91,0,15,0,116,0,47,0,88,0,71,0,41,0,36,0,188,0,217,0,122,0,0,0,143,0,198,0,111,0,233,0,52,0,193,0,95,0,180,0,125,0,14,0,166,0,109,0,206,0,84,0,209,0,123,0,169,0,21,0,173,0,207,0,87,0,96,0,132,0,252,0,22,0,31,0,60,0,94,0,209,0,68,0,12,0,157,0,104,0,79,0,168,0,44,0,63,0,48,0,95,0,74,0,10,0,192,0,125,0,147,0,16,0,110,0,210,0,33,0,200,0,109,0,124,0,218,0,1,0,182,0,154,0,39,0,244,0,26,0,149,0,138,0,184,0,125,0,94,0,127,0,198,0,32,0,88,0,214,0,79,0,143,0,157,0,125,0,9,0,6,0,27,0,196,0,177,0,143,0,173,0,31,0,139,0,138,0,55,0,193,0,127,0,94,0,129,0,61,0,19,0,20,0,243,0,3,0,213,0,38,0,0,0,12,0,18,0,56,0,221,0,39,0,125,0,158,0,177,0,199,0,230,0,39,0,201,0,228,0
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

      { searchKeySerializer } = service

      sinon.stub(service.credentialLoader, 'getCredentials').returns({ keypair })
      sinon.stub(searchKeySerializer.credentialLoader, 'getCredentials').returns({ keypair })
      _.extend(service, { searchKeyGenerator })

    afterEach ->
      service.credentialLoader.getCredentials.restore()
      service.searchKeySerializer.credentialLoader.getCredentials.restore()
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

          expect(fhePrivateKey).toEqual(BinaryUtils.stringToUint8('fhe.priv'))
          expect(searchPrivateKey).toEqual(BinaryUtils.stringToUint8('search.pvt'))
          expect(clientHashFunction).toEqual(BinaryUtils.stringToUint8('hash.fun'))

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
          clientHashFunction : ENCRYPTED_STORED_UINT8_KEY
        })

        service.getAllCredentials()
        .then (allCredentials) ->
          fhePrivateKey      = allCredentials.FHE_PRIVATE_KEY
          searchPrivateKey   = allCredentials.SEARCH_PRIVATE_KEY
          clientHashFunction = allCredentials.CLIENT_HASH_FUNCTION

          expect(fhePrivateKey).toEqual(BinaryUtils.stringToUint8('fhe.priv'))
          expect(searchPrivateKey).toEqual(BinaryUtils.stringToUint8('fhe.priv'))
          expect(clientHashFunction).toEqual(BinaryUtils.stringToUint8('fhe.priv'))

          done()
