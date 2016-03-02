# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.credential-service', [
  'require'
  'bluebird'
  'forge'
  'kryptnostic.logger'
  'kryptnostic.key-storage-api'
  'kryptnostic.binary-utils'
  'kryptnostic.rsa-key-generator'
  'kryptnostic.password-crypto-service'
  'kryptnostic.salt-generator'
  'kryptnostic.validators'
], (require) ->

  Logger                = require 'kryptnostic.logger'
  Forge                 = require 'forge'
  Promise               = require 'bluebird'
  BinaryUtils           = require 'kryptnostic.binary-utils'
  KeyStorageApi         = require 'kryptnostic.key-storage-api'
  PasswordCryptoService = require 'kryptnostic.password-crypto-service'
  RsaKeyGenerator       = require 'kryptnostic.rsa-key-generator'
  SaltGenerator         = require 'kryptnostic.salt-generator'
  Validators            = require 'kryptnostic.validators'

  DEFAULT_ITERATIONS = 1000
  DEFAULT_KEY_SIZE   = 256
  BITS_PER_BYTE      = 8

  {
    validateUuid,
  } = Validators

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

    deriveCredential : ({ principal, password }) ->
      Promise.resolve(
        KeyStorageApi.getEncryptedSalt(principal)
      )
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

      if not validateUuid(uuid)
        return Promise.resolve(null)

      Promise.resolve(
        KeyStorageApi.setEncryptedSalt(uuid, credential, encryptedSalt)
      )

    initializeKeypair : ({ password }) ->
      { publicKey, privateKey, keypair } = {}

      Promise.resolve(
        @rsaKeyGenerator.generateKeypair()
      )
      .then (keypairBuffer) ->

        keypair         = {}
        passwordCrypto  = new PasswordCryptoService()
        publicKeyBytes  = keypairBuffer.publicKey.data
        privateKeyBytes = keypairBuffer.privateKey.data

        publicKey  = publicKeyBytes
        privateKey = passwordCrypto.encrypt(privateKeyBytes, password)

        publicKeyAsn1      = Forge.asn1.fromDer(keypairBuffer.publicKey)
        keypair.publicKey  = Forge.pki.publicKeyFromAsn1(publicKeyAsn1)
        privateKeyAsn1     = Forge.asn1.fromDer(keypairBuffer.privateKey)
        keypair.privateKey = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
      .then ->
        KeyStorageApi.setRSAPrivateKey(privateKey)
      .then ->
        KeyStorageApi.setRSAPublicKey(publicKey)
      .then ->
        log.info('keypair initialization complete')
        return keypair
      .catch (e) ->
        log.error(e)
        log.error('keypair generation failed!', e)

    deriveKeyPair : ({ password }) ->
      Promise.resolve(
        KeyStorageApi.getRSAPrivateKey()
      )
      .then (blockCiphertext) =>
        if _.isEmpty(blockCiphertext)
          log.info('no keypair exists, generating on-the-fly')
          return Promise.resolve(
            @initializeKeypair({ password })
          )
        else
          log.info('using existing keypair')
          passwordCrypto   = new PasswordCryptoService()
          privateKeyBytes  = passwordCrypto.decrypt(blockCiphertext, password)
          privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
          privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
          privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
          publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

          return { privateKey, publicKey }

    verifyPublicKeyIntegrity: (principal, rsaKeyPair) ->

      if _.isEmpty(rsaKeyPair)
        return Promise.resolve()

      Promise.resolve(
        KeyStorageApi.getRSAPublicKey(principal)
      )
      .then (rsaPublicKeyAsUint8) =>

        publicKeyAsPem = null
        derivedPublicKeyAsPem = Forge.pki.publicKeyToPem(rsaKeyPair.publicKey)

        if rsaPublicKeyAsUint8?
          try
            publicKeyBytes = BinaryUtils.uint8ToString(rsaPublicKeyAsUint8)
            publicKeyBuffer = Forge.util.createBuffer(publicKeyBytes, 'raw')
            publicKeyAsAsn1 = Forge.asn1.fromDer(publicKeyBuffer)
            publicKey = Forge.pki.publicKeyFromAsn1(publicKeyAsAsn1)
            publicKeyAsPem = Forge.pki.publicKeyToPem(publicKey)
          catch e
            publicKeyAsPem = null

        # update the RSA public key if the stored key does not match the derived key
        if publicKeyAsPem != derivedPublicKeyAsPem
          publicKeyAsAsn1 = Forge.pki.publicKeyToAsn1(rsaKeyPair.publicKey)
          publicKeyAsDer = Forge.asn1.toDer(publicKeyAsAsn1)
          Promise.resolve(
            KeyStorageApi.setRSAPublicKey(publicKeyAsDer.data)
          )

      return

  return CredentialService
