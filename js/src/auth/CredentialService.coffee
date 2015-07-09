define 'soteria.credential-service', [
  'require'
  'forge'
  'soteria.directory-api'
  'soteria.password-crypto-service'
], (require, forge, dirApi, pcs) ->

  Forge                 = require 'forge'
  DirectoryApi          = require 'soteria.directory-api'
  PasswordCryptoService = require 'soteria.password-crypto-service'

  DEFAULT_ITERATIONS = 1000
  DEFAULT_KEY_SIZE   = 32

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
      @directoryApi = new DirectoryApi()

    deriveCredential : ({username, password, realm}) ->
      iterations     = DEFAULT_ITERATIONS
      keySize        = DEFAULT_KEY_SIZE
      passwordCrypto = new PasswordCryptoService(password)

      return @directoryApi.getSalt({username, realm})
      .then (encryptedSalt) ->
        salt           = passwordCrypto.decrypt(encryptedSalt)
        md             = Forge.sha1.create()
        derived        = Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md)
        hexDerived     = Forge.util.bytesToHex(derived)
        return hexDerived

    deriveKeypair : ({password}) ->
      passwordCrypto = new PasswordCryptoService(password)

      @directoryApi.getRsaKeys()
      .then (blockCiphertext) ->
        privateKeyBytes  = passwordCrypto.decrypt(blockCiphertext)
        privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw')
        privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer)
        privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1)
        publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e)

        return { privateKey, publicKey }

  return CredentialService
