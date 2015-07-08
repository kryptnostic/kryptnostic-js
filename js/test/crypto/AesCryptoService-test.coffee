
define [
  'require',
  'forge',
  'soteria.aes-crypto-service',
  'soteria.password-crypto-service',
], (require) ->

  AesCryptoService      = require 'soteria.aes-crypto-service'
  PasswordCryptoService = require 'soteria.password-crypto-service'
  Forge                 = require 'forge'

  describe 'AesCryptoService', ->

    it 'should be able to decrypt what it encrypts', ->
      key             = Forge.random.getBytesSync(PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE)
      cypher          = { algorithm: 'AES', mode: 'CTR' }
      cryptoService   = new AesCryptoService(cypher, key)
      plaintext       = "star wars NOPE yoda YUP"
      blockCiphertext = cryptoService.encrypt(plaintext)
      decrypted       = cryptoService.decrypt(blockCiphertext)
      expect(decrypted).toBe(plaintext)

