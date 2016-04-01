# coffeelint: disable=cyclomatic_complexity

define [
  'require'
  'forge'
  'sinon'
  'kryptnostic.authentication-stage'
  'kryptnostic.binary-utils'
  'kryptnostic.credential-service'
  'kryptnostic.key-storage-api'
  'kryptnostic.mock.mock-data-utils'
], (require) ->

  # libraries
  forge   = require 'forge'
  Promise = require 'bluebird'
  sinon   = require 'sinon'

  # apis
  KeyStorageApi = require 'kryptnostic.key-storage-api'

  # kryptnostic
  AuthenticationStage = require 'kryptnostic.authentication-stage'
  CredentialService = require 'kryptnostic.credential-service'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'
  MockDataUtils = require 'kryptnostic.mock.mock-data-utils'

  #
  # mock data
  #

  MOCK_USER_ID  = 'ec6865e6-e60e-424b-a071-6a9c1603d735'
  MOCK_PASSWORD = 'password'

  MOCK_CREDENTIAL_PAIR = MockDataUtils.generateMockCredentialPairFromPassword(MOCK_PASSWORD)
  MOCK_CREDENTIAL      = MOCK_CREDENTIAL_PAIR.mockCredential
  MOCK_ENCRYPTED_SALT  = MOCK_CREDENTIAL_PAIR.mockEncryptedSalt

  MOCK_RSA_KEY_PAIR_AS_PEM = MockDataUtils.MOCK_RSA_KEY_PAIR_AS_PEM
  MOCK_RSA_KEY_PAIR = {
    publicKey  : forge.pki.publicKeyFromPem(MOCK_RSA_KEY_PAIR_AS_PEM.publicKey),
    privateKey : forge.pki.privateKeyFromPem(MOCK_RSA_KEY_PAIR_AS_PEM.privateKey),
  }

  #
  # if we don't redo these forge transformations each time we use MOCK_RSA_KEY_PAIR_AS_DER, then forge throws an
  # exception when we try to do forge.asn1.fromDer() on the keys in MOCK_RSA_KEY_PAIR_AS_DER. it's unclear as to why
  # forge is complaining, so for now, we'll just have to get around it by doing these transformations every time
  #
  MOCK_RSA_KEY_PAIR_AS_DER = ->
    return {
      publicKey  : forge.asn1.toDer(forge.pki.publicKeyToAsn1(MOCK_RSA_KEY_PAIR.publicKey)),
      privateKey : forge.asn1.toDer(forge.pki.privateKeyToAsn1(MOCK_RSA_KEY_PAIR.privateKey))
    }

  MOCK_RSA_PRIVATE_KEY_ENCRYPTED = MockDataUtils.generateMockBlockCipherTextEncryptedWithPassword(
    MOCK_RSA_KEY_PAIR_AS_DER().privateKey.data,
    MOCK_PASSWORD
  )

  #
  # helper functions
  #

  assertKeyPairEquality = (actualKeyPair, expectedKeyPairAsPEM) ->

    expect(actualKeyPair).toBeDefined()

    actualPublicKey = actualKeyPair.publicKey
    actualPublicKeyAsPem = forge.pki.publicKeyToPem(actualPublicKey)
    expect(actualPublicKeyAsPem).toEqual(expectedKeyPairAsPEM.publicKey)

    actualPrivateKey = actualKeyPair.privateKey
    actualPrivateKeyAsPem = forge.pki.privateKeyToPem(actualPrivateKey)
    expect(actualPrivateKeyAsPem).toEqual(expectedKeyPairAsPEM.privateKey)

  #
  # tests
  #

  getPublicKeyStub     = null
  setPublicKeyStub     = null
  getPrivateKeyStub    = null
  setPrivateKeyStub    = null
  setEncryptedSaltStub = null

  beforeAll ->
    getPublicKeyStub     = sinon.stub(KeyStorageApi, 'getRSAPublicKey')
    setPublicKeyStub     = sinon.stub(KeyStorageApi, 'setRSAPublicKey')
    getPrivateKeyStub    = sinon.stub(KeyStorageApi, 'getRSAPrivateKey')
    setPrivateKeyStub    = sinon.stub(KeyStorageApi, 'setRSAPrivateKey')
    setEncryptedSaltStub = sinon.stub(KeyStorageApi, 'setEncryptedSalt')
    sinon.stub(KeyStorageApi, 'getEncryptedSalt').returns(MOCK_ENCRYPTED_SALT)

  afterAll ->
    getPublicKeyStub     = null
    setPublicKeyStub     = null
    getPrivateKeyStub    = null
    setPrivateKeyStub    = null
    setEncryptedSaltStub = null
    KeyStorageApi.getRSAPublicKey.restore()
    KeyStorageApi.setRSAPublicKey.restore()
    KeyStorageApi.getRSAPrivateKey.restore()
    KeyStorageApi.setRSAPrivateKey.restore()
    KeyStorageApi.getEncryptedSalt.restore()

  describe 'CredentialService', ->

    describe 'initializeSalt()', ->

      beforeEach ->
        KeyStorageApi.setEncryptedSalt.reset()

      it 'should not call KeyStorageApi.setEncryptedSalt() if the user UUID is invalid', (done) ->

        credentialService = new CredentialService()
        credentialService.initializeSalt({
          uuid          : null,
          credential    : MOCK_CREDENTIAL,
          encryptedSalt : MOCK_ENCRYPTED_SALT
        })
        .then ->
          sinon.assert.notCalled(setEncryptedSaltStub)
          done()
        .catch (e) ->
          done.fail(e)

      it 'should call KeyStorageApi.setEncryptedSalt() with the correct parameters', (done) ->

        credentialService = new CredentialService()
        credentialService.initializeSalt({
          uuid          : MOCK_USER_ID,
          credential    : MOCK_CREDENTIAL,
          encryptedSalt : MOCK_ENCRYPTED_SALT
        })
        .then ->
          sinon.assert.calledOnce(setEncryptedSaltStub)
          sinon.assert.calledWith(setEncryptedSaltStub, MOCK_USER_ID, MOCK_CREDENTIAL, MOCK_ENCRYPTED_SALT)
          done()
        .catch (e) ->
          done.fail(e)

    describe 'generateCredentialPair()', ->

      it 'should fail', ->

        generateCredentialPair = ->
          CredentialService.generateCredentialPair(null)
        expect(generateCredentialPair).toThrow()

        generateCredentialPair = ->
          CredentialService.generateCredentialPair({})
        expect(generateCredentialPair).toThrow()

        generateCredentialPair = ->
          CredentialService.generateCredentialPair({ password: null })
        expect(generateCredentialPair).toThrow()

      it 'should generate the credential and encrypted salt from the password', ->

        pair = CredentialService.generateCredentialPair({
          password: MOCK_PASSWORD
        })

        expect(pair).toBeDefined()
        expect(pair.credential).toBeDefined()
        expect(pair.encryptedSalt).toBeDefined()

    describe 'derive()', ->

      it 'should derive the credential from encrypted salt and password', ->

        derivedCredential = CredentialService.derive({
          encryptedSalt : MOCK_ENCRYPTED_SALT,
          password      : MOCK_PASSWORD
        })

        expect(derivedCredential).toBeDefined()
        expect(derivedCredential).toEqual(MOCK_CREDENTIAL)

    describe 'deriveCredential()', ->

      it 'should derive the credential from encrypted salt and password', (done) ->

        credentialService = new CredentialService()
        credentialService.deriveCredential({
          principal : MOCK_USER_ID,
          password  : MOCK_PASSWORD
        })
        .then (derivedCredential) ->
          expect(derivedCredential).toBeDefined()
          expect(derivedCredential).toEqual(MOCK_CREDENTIAL)
          done()
        .catch (e) ->
          done.fail(e)

    describe 'initializeKeypair()', ->

      beforeEach ->
        setPublicKeyStub.reset()
        getPrivateKeyStub.reset()
        setPrivateKeyStub.reset()

      it 'should generate a new RSA key pair, and upload both keys', (done) ->

        credentialService = new CredentialService()

        sinon.stub(credentialService.rsaKeyGenerator, 'generateKeypair')
          .returns(Promise.resolve(MOCK_RSA_KEY_PAIR_AS_DER()))
        sinon.stub(credentialService.userDirectoryApi, 'notifyFirstLogin')
          .returns(Promise.resolve())

        rsaKeyPairGenCompleteCallbackSpy = sinon.spy()

        credentialService.initializeKeypair(
          { password: MOCK_PASSWORD },
          rsaKeyPairGenCompleteCallbackSpy
        )
        .then (rsaKeyPair) ->

          assertKeyPairEquality(rsaKeyPair, MOCK_RSA_KEY_PAIR_AS_PEM)

          sinon.assert.calledOnce(setPublicKeyStub)
          # ToDo - check that KeyStorageApi.setRSAPublicKey() was called with the correct public key
          # sinon.assert.calledWith(spy, arg1)

          sinon.assert.calledOnce(setPrivateKeyStub)
          # ToDo - check that KeyStorageApi.setRSAPrivateKey() was called with the correct private key
          # sinon.assert.calledWith(spy, arg1)

          sinon.assert.calledWith(
            rsaKeyPairGenCompleteCallbackSpy,
            AuthenticationStage.KEYPAIR_GEN_COMPLETE
          )

          done()

        .catch (e) ->
          done.fail(e)

    describe 'deriveKeyPair()', ->

      beforeEach ->
        setPublicKeyStub.reset()
        getPrivateKeyStub.reset()
        setPrivateKeyStub.reset()

      it 'should generate a new RSA key pair, and upload both keys', (done) ->

        credentialService = new CredentialService()
        sinon.stub(credentialService.rsaKeyGenerator, 'generateKeypair')
          .returns(Promise.resolve(MOCK_RSA_KEY_PAIR_AS_DER()))
        sinon.stub(credentialService.userDirectoryApi, 'notifyFirstLogin')
          .returns(Promise.resolve())

        rsaKeyPairGenCompleteCallbackSpy = sinon.spy()

        credentialService.deriveKeyPair(
          { password: MOCK_PASSWORD },
          rsaKeyPairGenCompleteCallbackSpy
        )
        .then (rsaKeyPair) ->
          assertKeyPairEquality(rsaKeyPair, MOCK_RSA_KEY_PAIR_AS_PEM)
          sinon.assert.calledOnce(setPublicKeyStub)
          sinon.assert.calledOnce(setPrivateKeyStub)
          sinon.assert.calledWith(
            rsaKeyPairGenCompleteCallbackSpy,
            AuthenticationStage.KEYPAIR_GEN_COMPLETE
          )
          done()
        .catch (e) ->
          done.fail(e)

      it 'should derive RSA key pair from existing RSA private key', (done) ->

        getPrivateKeyStub.returns(Promise.resolve(MOCK_RSA_PRIVATE_KEY_ENCRYPTED))

        rsaKeyPairGenCompleteCallbackSpy = sinon.spy()

        credentialService = new CredentialService()
        credentialService.deriveKeyPair(
          { password: MOCK_PASSWORD },
          rsaKeyPairGenCompleteCallbackSpy
        )
        .then (rsaKeyPair) ->
          assertKeyPairEquality(rsaKeyPair, MOCK_RSA_KEY_PAIR_AS_PEM)
          sinon.assert.notCalled(setPublicKeyStub)
          sinon.assert.notCalled(setPrivateKeyStub)
          sinon.assert.calledOnce(getPrivateKeyStub)
          sinon.assert.notCalled(rsaKeyPairGenCompleteCallbackSpy)
          done()
        .catch (e) ->
          done.fail(e)

    describe 'ensureValidRSAPublickKey()', ->

      beforeEach ->
        getPublicKeyStub.reset()
        setPublicKeyStub.reset()
        getPrivateKeyStub.reset()
        setPrivateKeyStub.reset()

      it 'should not do anything if the user UUID (principal) is invalid', (done) ->

        credentialService = new CredentialService()
        credentialService.ensureValidRSAPublickKey(null, MOCK_RSA_KEY_PAIR)
        .then ->
          sinon.assert.notCalled(getPublicKeyStub)
          sinon.assert.notCalled(setPublicKeyStub)
          done()
        .catch (e) ->
          done.fail(e)

      it 'should not do anything if the RSA key pair is invalid', (done) ->

        credentialService = new CredentialService()
        credentialService.ensureValidRSAPublickKey(MOCK_USER_ID, {})
        .then ->
          sinon.assert.notCalled(getPublicKeyStub)
          sinon.assert.notCalled(setPublicKeyStub)
          done()
        .catch (e) ->
          done.fail(e)

      it 'should not set the RSA public key if the stored key matches the derived key', (done) ->

        publicKeyBytes = MOCK_RSA_KEY_PAIR_AS_DER().publicKey.data
        publicKeyAsUint8 = BinaryUtils.stringToUint8(publicKeyBytes)
        getPublicKeyStub.returns(Promise.resolve(publicKeyAsUint8))

        credentialService = new CredentialService()
        credentialService.ensureValidRSAPublickKey(MOCK_USER_ID, MOCK_RSA_KEY_PAIR)
        .then ->
          sinon.assert.calledOnce(getPublicKeyStub)
          sinon.assert.calledWith(getPublicKeyStub, MOCK_USER_ID)
          sinon.assert.notCalled(setPublicKeyStub)
          done()
        .catch (e) ->
          done.fail(e)

      it 'should set the RSA public key if the stored key does not match the derived key', (done) ->

        getPublicKeyStub.returns(Promise.resolve(null))

        credentialService = new CredentialService()
        credentialService.ensureValidRSAPublickKey(MOCK_USER_ID, MOCK_RSA_KEY_PAIR)
        .then ->
          sinon.assert.calledOnce(getPublicKeyStub)
          sinon.assert.calledWith(getPublicKeyStub, MOCK_USER_ID)
          sinon.assert.calledOnce(setPublicKeyStub)
          sinon.assert.calledWith(setPublicKeyStub, MOCK_RSA_KEY_PAIR_AS_DER().publicKey.data)
          done()
        .catch (e) ->
          done.fail(e)
