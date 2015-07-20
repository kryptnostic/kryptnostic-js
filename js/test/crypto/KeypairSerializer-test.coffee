define [
  'require'
  'forge'
  'soteria.keypair-serializer'
], (require) ->

  Forge             = require 'forge'
  KeypairSerializer = require 'soteria.keypair-serializer'

  TEST_ENCRYPT_MESSAGE = 'foo'

  describe 'KeypairSerializer', ->

    it 'should serialize and deserialize a keypair which can still decrypt messages', ->
      keypair               = Forge.rsa.generateKeyPair({bits: 2048, e: 0x10001})
      deserialized          = KeypairSerializer.hydrate(KeypairSerializer.serialize(keypair))

      keypairEncrypted      = keypair.publicKey.encrypt(TEST_ENCRYPT_MESSAGE)
      deserializedDecrypted = deserialized.privateKey.decrypt(keypairEncrypted)

      expect(deserializedDecrypted).toBe(TEST_ENCRYPT_MESSAGE)

    it 'should serialize and deserialize a keypair which can still encrypt messages', ->
      keypair               = Forge.rsa.generateKeyPair({bits: 2048, e: 0x10001})
      deserialized          = KeypairSerializer.hydrate(KeypairSerializer.serialize(keypair))

      deserializedEncrypted = deserialized.publicKey.encrypt(TEST_ENCRYPT_MESSAGE)
      keypairDecrypted      = keypair.privateKey.decrypt(deserializedEncrypted)

      expect(keypairDecrypted).toBe(TEST_ENCRYPT_MESSAGE)
