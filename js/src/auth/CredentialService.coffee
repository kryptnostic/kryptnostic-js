define 'kryptnostic.credential-service', [
  'require'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.key-storage-api'
  'kryptnostic.binary-utils'
  'kryptnostic.rsa-key-generator'
  'kryptnostic.password-crypto-service'
  'kryptnostic.authentication-stage'
  'kryptnostic.salt-generator'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  Forge                 = require 'forge'
  Promise               = require 'bluebird'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  KeyStorageApi         = require 'kryptnostic.key-storage-api'
  PasswordCryptoService = require 'kryptnostic.password-crypto-service'
  RsaKeyGenerator       = require 'kryptnostic.rsa-key-generator'
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
        return CredentialService.derive({ encryptedSalt, password })

    @derive : ({ encryptedSalt, password }) ->
      passwordCrypto = new PasswordCryptoService()

      iterations = DEFAULT_ITERATIONS
      keySize    = DEFAULT_KEY_SIZE / BITS_PER_BYTE
      salt       = passwordCrypto.decrypt(encryptedSalt, password)
      md         = Forge.sha1.create()
      derived    = Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md)
      hexDerived = Forge.util.bytesToHex(derived)

      return hexDerived

    @generateCredentialPair : ({ password }) ->
      log.info('generating a new credential pair')
      salt           = SaltGenerator.generateSalt(DEFAULT_KEY_SIZE / BITS_PER_BYTE)
      passwordCrypto = new PasswordCryptoService()
      encryptedSalt  = passwordCrypto.encrypt(salt, password)
      credential     = CredentialService.derive({ password, encryptedSalt })
      return { credential, encryptedSalt }

    initializeSalt : ({ uuid, encryptedSalt, credential }) ->
      Promise.resolve()
      .then =>
        blockCiphertext = encryptedSalt
        KeyStorageApi.setEncryptedSalt(uuid, credential, blockCiphertext)
        return

    initializeKeypair : ({ password }, notifier = -> ) ->
      { publicKey, privateKey, keypair } = {}

      Promise.resolve()
      .then ->
        Promise.resolve(notifier(AuthenticationStage.RSA_KEYGEN))
      .then =>
        @rsaKeyGenerator.generateKeypair()
      .then (keypairBuffer) ->

        keypair         = {}
        passwordCrypto  = new PasswordCryptoService()
        publicKeyBytes  = keypairBuffer.publicKey.data
        privateKeyBytes = keypairBuffer.privateKey.data

        publicKey  = publicKeyBytes
        privateKey = passwordCrypto.encrypt(privateKeyBytes, password)

        publicKeyAsn1      = Forge.asn1.fromDer(publicKeyBytes)
        keypair.publicKey  = Forge.pki.publicKeyFromAsn1(publicKeyAsn1)
        privateKeyAsn1     = Forge.asn1.fromDer(privateKeyBytes)
        keypair.privateKey = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
        return keypair
      .then =>
        KeyStorageApi.setRSAPrivateKey(privateKey)
      .then =>
        publicKeyAsUint8 = BinaryUtils.stringToUint8(publicKey)
        KeyStorageApi.setRSAPublicKey(publicKeyAsUint8)
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
          privateKeyBytes  = passwordCrypto.decrypt(blockCiphertext, password)
          privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
          privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
          privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
          publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

          return { privateKey, publicKey }

  return CredentialService
