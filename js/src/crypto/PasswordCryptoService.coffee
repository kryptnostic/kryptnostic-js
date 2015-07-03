define 'soteria.password-crypto-service', [
  'require',
  'forge.min',
  'soteria.abstract-crypto-service'
], (require) ->
  'use strict'

  Forge                 = require('forge.min')
  AbstractCryptoService = require('soteria.abstract-crypto-service')

  DEFAULT_ALGORITHM     = 'AES'
  DEFAULT_MODE          = 'CTR'

  BLOCK_CIPHER_ITERATIONS = 128
  BLOCK_CIPHER_KEY_SIZE   = 16

  derive = (password, salt, iterations, keySize) ->
    md = Forge.sha1.create();
    return Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md);

  #
  # Author: nickdhewitt, rbuckheit
  #
  class PasswordCryptoService

    constructor: (@password) ->
      @abstractCryptoService = new AbstractCryptoService({ algorithm: DEFAULT_ALGORITHM, mode: DEFAULT_MODE })

    encrypt: (plaintext) ->
      salt     = Forge.random.getBytesSync(BLOCK_CIPHER_KEY_SIZE)
      key      = derive(@password, salt, BLOCK_CIPHER_ITERATIONS, BLOCK_CIPHER_KEY_SIZE)
      iv       = Forge.random.getBytesSync(BLOCK_CIPHER_KEY_SIZE)
      contents = @abstractCryptoService.encrypt(key, iv, plaintext)

      return {
        key      : btoa(key)
        contents : btoa(contents)
        iv       : btoa(iv)
        salt     : btoa(salt)
      }

    decrypt: (blockCiphertext) ->
      key      = derive(@password, atob(blockCiphertext.salt), BLOCK_CIPHER_ITERATIONS, BLOCK_CIPHER_KEY_SIZE)
      iv       = atob(blockCiphertext.iv)
      contents = atob(blockCiphertext.contents)

      return @abstractCryptoService.decrypt(key, iv, contents)

    _derive: (password, salt, iterations, keySize) ->
      return derive(password, salt, iterations, keySize);

  return PasswordCryptoService;
