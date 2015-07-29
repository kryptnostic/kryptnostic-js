define 'kryptnostic.credential-service', [
  'require'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.public-key-envelope'
  'kryptnostic.directory-api'
  'kryptnostic.rsa-key-generator'
  'kryptnostic.password-crypto-service'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  Forge                 = require 'forge'
  Promise               = require 'bluebird'
  DirectoryApi          = require 'kryptnostic.directory-api'
  PasswordCryptoService = require 'kryptnostic.password-crypto-service'
  RsaKeyGenerator       = require 'kryptnostic.rsa-key-generator'
  PublicKeyEnvelope     = require 'kryptnostic.public-key-envelope'

  DEFAULT_ITERATIONS = 1000
  DEFAULT_KEY_SIZE   = 32

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
      @directoryApi    = new DirectoryApi()
      @rsaKeyGenerator = new RsaKeyGenerator()

    deriveCredential : ({ username, password, realm }) ->
      iterations     = DEFAULT_ITERATIONS
      keySize        = DEFAULT_KEY_SIZE
      passwordCrypto = new PasswordCryptoService()

      return @directoryApi.getSalt({ username, realm })
      .then (encryptedSalt) ->
        salt           = passwordCrypto.decrypt(encryptedSalt, password)
        md             = Forge.sha1.create()
        derived        = Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md)
        hexDerived     = Forge.util.bytesToHex(derived)
        return hexDerived

    initializeKeypair : ({ password }) ->
      log.info('initializeKeypair')
      { publicKey, privateKey, keypair } = {}

      Promise.resolve()
      .then =>
        keypair        = @rsaKeyGenerator.generateKeypair()
        passwordCrypto = new PasswordCryptoService()

        privateKeyAsn1       = Forge.pki.privateKeyToAsn1(keypair.privateKey)
        privateKeyBuffer     = Forge.asn1.toDer(privateKeyAsn1)
        serializedPrivateKey = privateKeyBuffer.data

        privateKey = passwordCrypto.encrypt(serializedPrivateKey, password)

        publicKeyAsn1       = Forge.pki.publicKeyToAsn1(keypair.publicKey)
        publicKeyBuffer     = Forge.asn1.toDer(publicKeyAsn1)
        serializedPublicKey = publicKeyBuffer.data

        publicKey = PublicKeyEnvelope.createFromBuffer(serializedPublicKey)
      .then =>
        @directoryApi.setPrivateKey(privateKey)
      .then =>
        @directoryApi.setPublicKey(publicKey)
      .then ->
        log.info('keypair initialization complete')
        return keypair
      .catch (e) ->
        log.error(e)
        log.error('keypair generation failed!', e)

    deriveKeypair : ({ password }) ->
      Promise.resolve()
      .then =>
        @directoryApi.getPrivateKey()
      .then (blockCiphertext) =>
        if _.isEmpty(blockCiphertext)
          log.info('no keypair exists, generating on-the-fly')
          return Promise.resolve(@initializeKeypair({ password }))
        else
          log.info('using existing keypair')
          passwordCrypto = new PasswordCryptoService()
          privateKeyBytes  = passwordCrypto.decrypt(blockCiphertext, password)
          privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
          privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
          privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
          publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

          return { privateKey, publicKey }

  return CredentialService
