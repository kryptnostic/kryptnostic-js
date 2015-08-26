define [
  'require'
  'forge'
  'kryptnostic.search-credential-service'
  'kryptnostic.mock.kryptnostic-engine'
], (require) ->

  Forge                   = require 'forge'
  SearchCredentialService = require 'kryptnostic.search-credential-service'
  MockKryptnosticEngine   = require 'kryptnostic.mock.kryptnostic-engine'

  # mock data
  # =========

  DEMO_PLAINTEXT = 'foo foo foo'
  DEMO_CIPHERTEXT_BASE64 =
    'kUolqTlsUr0EwGmjRR099EANNkR6ZQdRTugBhcYu2jYjYfrJ7F0imAKcELKidw+VUZeb6vKJsO0rLFwly54Duw=='
  DEMO_CIPHERTEXT =
    atob(DEMO_CIPHERTEXT_BASE64)

  #
  # if you need to generate a new mock key, use:
  # openssl genrsa -des3 -out private.pem 512
  # openssl rsa -in private.pem -out private_unencrypted.pem -outform PEM
  #

  MOCK_PEM_RSA_PRIVATE_KEY = '-----BEGIN RSA PRIVATE KEY-----\
    MIIBOgIBAAJBANZv7UhNhG0WYhxnGjpliruomqpSzf4Cq8+GnfGrYxTiuY4Rk0yf\
    dpliVS5wf04HksnjeoHZPd2mLV2GtQTsFa0CAwEAAQJAfRrhyYwIFYi4hq+UOruh\
    G+i7C2Gx8l7mk/WK0kLWVIj8qASyd5WLSyL/s4M++ws1CyzXimvgeLS88SZqWElF\
    VQIhAOx9E70w2cSDzT8HIyMowcbsv9ZX9+GXvuuh5zfhDza3AiEA6CEZMM9G3WR8\
    cst7OGqz+4hjn+/f/RSEMzzvrvZ70rsCIQCuOIMHOOrljFfzm/V13HvNafL2HL6A\
    EsPTYeYuU35axwIgeLalo/VWk9EqyoO4u3j5yed+b3DN2Y1uxjp9Jk51y/sCIFcG\
    L0tuyBA107pX0CaxvZpNSWJJmKhhzdPGIptPEjmL\
    -----END RSA PRIVATE KEY-----'

  # tests
  # =====

  describe 'SearchCredentialService', ->

    { service }  = {}

    beforeEach ->
      # rsa key init
      privateKey = Forge.pki.privateKeyFromPem(MOCK_PEM_RSA_PRIVATE_KEY)
      publicKey  = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)
      keypair    = { privateKey, publicKey }

      # service instantiation
      kryptnosticEngine = new MockKryptnosticEngine()
      service           = new SearchCredentialService()

      # mocking
      sinon.stub(service.credentialLoader, 'getCredentials').returns({ keypair })
      _.extend(service, { kryptnosticEngine })

    afterEach ->
      service.cryptoKeyStorageApi.getFhePrivateKey.restore()
      service.credentialLoader.getCredentials.restore()

    describe '#getFhePrivateKey', ->

      it 'should initialize and store a key if it does not exist', (done) ->
        { storedCiphertext } = {}

        sinon.stub(service.cryptoKeyStorageApi, 'getFhePrivateKey').returns(undefined)
        sinon.stub(service.cryptoKeyStorageApi, 'setFhePrivateKey', (ciphertext) ->
          storedCiphertext = ciphertext
          return Promise.resolve()
        )
        service.getFhePrivateKey()
        .then (keyString) ->
          expect(keyString).toBe('fhe.pvt')
          expect(storedCiphertext).toBeDefined()
          expect(storedCiphertext.constructor.name).toBe('String')
          done()

      it 'should load a key if it exists', (done) ->
        sinon.stub(service.cryptoKeyStorageApi, 'getFhePrivateKey').returns(DEMO_CIPHERTEXT)
        service.getFhePrivateKey()
        .then (keyString) ->
          expect(keyString).toBe(DEMO_PLAINTEXT)
          done()
