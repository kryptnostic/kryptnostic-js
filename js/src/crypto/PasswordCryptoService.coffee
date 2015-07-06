define 'soteria.password-crypto-service', [
  'require',
  'forge',
  'soteria.abstract-crypto-service'
], (require) ->
  'use strict'

  Forge                 = require('forge')
  AbstractCryptoService = require('soteria.abstract-crypto-service')

  DEFAULT_ALGORITHM     = 'AES'
  DEFAULT_MODE          = 'CTR'


  derive = (password, salt, iterations, keySize) ->
    md = Forge.sha1.create();
    return Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md);

  #
  # Author: nickdhewitt, rbuckheit
  #
  class PasswordCryptoService

    @BLOCK_CIPHER_ITERATIONS : 128

    @BLOCK_CIPHER_KEY_SIZE  : 16

    constructor: (@password) ->
      @abstractCryptoService = new AbstractCryptoService({ algorithm: DEFAULT_ALGORITHM, mode: DEFAULT_MODE })

    encrypt: (plaintext) ->
      salt     = Forge.random.getBytesSync(PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE)
      key      = derive(@password, salt, PasswordCryptoService.BLOCK_CIPHER_ITERATIONS, PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE)
      iv       = Forge.random.getBytesSync(PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE)
      contents = @abstractCryptoService.encrypt(key, iv, plaintext)

      return {
        key      : btoa(key)
        contents : btoa(contents)
        iv       : btoa(iv)
        salt     : btoa(salt)
      }

    decrypt: (blockCiphertext) ->
      key      = derive(@password, atob(blockCiphertext.salt), PasswordCryptoService.BLOCK_CIPHER_ITERATIONS, PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE)
      iv       = atob(blockCiphertext.iv)
      contents = atob(blockCiphertext.contents)

      return @abstractCryptoService.decrypt(key, iv, contents)

    _derive: (password, salt, iterations, keySize) ->
      return derive(password, salt, iterations, keySize);

  return PasswordCryptoService;
