define 'kryptnostic.credential-service', [
  'require'
  'bluebird'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.public-key-envelope'
  'kryptnostic.key-storage-api'
  'kryptnostic.rsa-key-generator'
  'kryptnostic.password-crypto-service'
  'kryptnostic.authentication-stage'
  'kryptnostic.salt-generator'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  Forge                 = require 'forge'
  Promise               = require 'bluebird'
  KeyStorageApi         = require 'kryptnostic.key-storage-api'
  PasswordCryptoService = require 'kryptnostic.password-crypto-service'
  RsaKeyGenerator       = require 'kryptnostic.rsa-key-generator'
  PublicKeyEnvelope     = require 'kryptnostic.public-key-envelope'
  AuthenticationStage   = require 'kryptnostic.authentication-stage'
  SaltGenerator         = require 'kryptnostic.salt-generator'

  DEFAULT_ITERATIONS = 1000
  DEFAULT_KEY_SIZE   = 256
  BITS_PER_BYTE      = 8

  log = Logger.get('CredentialService')

  #
  # Service for deriving the credential from a user-provided password and encrypted salt.
  # This class is designed to be used one-time at user login when the password is available.
  # At that time, all credentials derived from the password should be computed here so that
  # the password can be discarded and garbage collected.
  #
  # Author: rbuckheit
  #
  class CredentialService

    constructor: ->
      @rsaKeyGenerator = new RsaKeyGenerator()

    deriveCredential : ({ principal, password }, notifier = -> ) ->
      { passwordCrypto } = {}

      Promise.resolve()
      .then ->
        Promise.resolve(notifier(AuthenticationStage.DERIVE_CREDENTIAL))
      .then =>
        KeyStorageApi.getEncryptedSalt(principal)
      .then (encryptedSalt) ->
        Promise.resolve(
          CredentialService.derive({ encryptedSalt, password })
        )
        .then (credential) ->
          return credential

    @derive : ({ encryptedSalt, password }) ->
      passwordCrypto = new PasswordCryptoService()
      Promise.resolve(
        passwordCrypto.decrypt(encryptedSalt, password)
      )
      .then (salt) ->
        iterations = DEFAULT_ITERATIONS
        keySize    = DEFAULT_KEY_SIZE / BITS_PER_BYTE
        md         = Forge.sha1.create()
        derived    = Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md)
        hexDerived = Forge.util.bytesToHex(derived)
        return hexDerived

    @generateCredentialPair : ({ password }) ->
      log.info('generating a new credential pair')
      salt           = SaltGenerator.generateSalt(DEFAULT_KEY_SIZE / BITS_PER_BYTE)
      passwordCrypto = new PasswordCryptoService()
      Promise.resolve(
        passwordCrypto.encrypt(salt, password)
      )
      .then (encryptedSalt) ->
        Promise.resolve(
          CredentialService.derive({ encryptedSalt, password })
        )
        .then (credential) ->
          return { credential, encryptedSalt }

    initializeSalt : ({ uuid, encryptedSalt, credential }) ->
      Promise.resolve()
      .then =>
        blockCiphertext = encryptedSalt
        KeyStorageApi.setEncryptedSalt(uuid, credential, blockCiphertext)

    initializeKeypair : ({ password }, notifier = -> ) ->
      { publicKey, privateKey, keypair } = {}

      Promise.resolve()
      .then ->
        Promise.resolve(notifier(AuthenticationStage.RSA_KEYGEN))
      .then =>
        @rsaKeyGenerator.generateKeypair()
      .then (keypairBuffer) =>
        passwordCrypto       = new PasswordCryptoService()
        serializedPrivateKey = keypairBuffer.privateKey.data
        serializedPublicKey  = keypairBuffer.publicKey.data
        Promise.resolve(
          passwordCrypto.encrypt(serializedPrivateKey, password)
        )
        .then (_privateKey) =>
          keypair            = {}
          privateKey         = _privateKey
          publicKey          = PublicKeyEnvelope.createFromBuffer(serializedPublicKey)
          privateKeyAsn1     = Forge.asn1.fromDer(serializedPrivateKey)
          keypair.privateKey = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
          publicKeyAsn1      = Forge.asn1.fromDer(serializedPublicKey)
          keypair.publicKey  = Forge.pki.publicKeyFromAsn1(publicKeyAsn1)
        .then =>
          KeyStorageApi.setRSAPrivateKey(privateKey)
        .then =>
          KeyStorageApi.setRSAPublicKey(publicKey)
        .then ->
          log.info('keypair initialization complete')
          return keypair
      .catch (e) ->
        log.error(e)
        log.error('keypair generation failed!', e)

    deriveKeypair : ({ password }, notifier = -> ) ->
      Promise.resolve()
      .then ->
        Promise.resolve(notifier(AuthenticationStage.DERIVE_KEYPAIR))
      .then =>
        KeyStorageApi.getRSAPrivateKey()
      .then (blockCiphertext) =>
        if _.isEmpty(blockCiphertext)
          return Promise.resolve()
          .then =>
            log.info('no keypair exists, generating on-the-fly')
            Promise.resolve(@initializeKeypair({ password }, notifier))
        else
          log.info('using existing keypair')
          passwordCrypto   = new PasswordCryptoService()
          Promise.resolve(
            passwordCrypto.decrypt(blockCiphertext, password)
          )
          .then (privateKeyBytes) ->
            privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
            privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
            privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
            publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)
            return { privateKey, publicKey }

  return CredentialService
