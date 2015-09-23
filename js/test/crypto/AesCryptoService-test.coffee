define [
  'require',
  'forge',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.block-ciphertext'
], (require) ->

  AesCryptoService      = require 'kryptnostic.aes-crypto-service'
  Forge                 = require 'forge'
  BlockCiphertext       = require 'kryptnostic.block-ciphertext'

  CYPHER = { algorithm: 'AES', mode: 'CTR' }

  cryptoService = undefined

  beforeEach ->
    key           = Forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE)
    cryptoService = new AesCryptoService(CYPHER, key)

  describe 'AesCryptoService', ->

    describe '#BLOCK_CIPHER_KEY_SIZE', ->

      it 'should be 16 bytes', ->
        expect(AesCryptoService.BLOCK_CIPHER_KEY_SIZE).toBe(16)

    describe '#encrypt', ->

      it 'should produce a block ciphertext', ->
        plaintext       = 'convert to block ciphertext'
        blockCiphertext = cryptoService.encrypt(plaintext)
        expect(blockCiphertext.constructor.name).toBe('BlockCiphertext')
        expect(blockCiphertext.iv).toBeDefined()
        expect(blockCiphertext.contents).toBeDefined()

      it 'should produce an initialization vector in base 64 with a binary length of 16 bytes', ->
        plaintext       = 'convert to block ciphertext'
        blockCiphertext = cryptoService.encrypt(plaintext)
        byteCount       = Forge.util.createBuffer(atob(blockCiphertext.iv), 'raw').length()
        expect(byteCount).toBe(16)

    describe '#decrypt', ->

      it 'should be able to decrypt what it encrypts', ->
        plaintext       = 'sensitive data'
        blockCiphertext = cryptoService.encrypt(plaintext)
        decrypted       = cryptoService.decrypt(blockCiphertext)
        expect(decrypted).toBe(plaintext)

      it 'should decrypt a known value with fixed inputs', ->
        plaintext       = 'convert to block ciphertext'
        key             = atob('GM+ZAeNk3c/SLmSWXxbt1g==')
        cryptoService   = new AesCryptoService(CYPHER, key)
        blockCiphertext = new BlockCiphertext {
          iv       : 'Et6ji2/KuWvWphFvvdntsg=='
          salt     : ''
          contents : '+5q3O/6m8AcIH+iJQGj0X5BXHABqjjPJlV4j'
        }
        expect(cryptoService.decrypt(blockCiphertext)).toBe(plaintext)

