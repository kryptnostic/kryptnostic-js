define 'soteria.credential-service', [
  'require'
  'forge'
  'soteria.directory-api'
  'soteria.password-crypto-service'
], (require) ->

  Forge                 = require 'forge'
  DirectoryApi          = require 'soteria.directory-api'
  PasswordCryptoService = require 'soteria.password-crypto-service'

  DEFAULT_ITERATIONS = 1000
  DEFAULT_KEY_SIZE   = 32

  #
  # Service for deriving the credential from a user-provided password and encrypted salt.
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
        hexDerived     = Forge.util.bytesToHex(derived);
        return hexDerived
