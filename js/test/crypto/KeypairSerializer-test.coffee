define [
  'require'
  'forge'
  'soteria.keypair-serializer'
], (require) ->

  Forge             = require 'forge'
  KeypairSerializer = require 'soteria.keypair-serializer'

  TEST_ENCRYPT_MESSAGE = 'foo'

  describe 'KeypairSerializer', ->

    it 'should serialize and hygrate a keypair which can still decrypt messages', ->

      keypair               = Forge.rsa.generateKeyPair({bits: 2048, e: 0x10001})
      serialized            = KeypairSerializer.serialize(keypair)
      deserialized          = KeypairSerializer.hydrate(serialized)

      keypairEncrypted      = keypair.publicKey.encrypt(TEST_ENCRYPT_MESSAGE)
      deserializedEncrypted = deserialized.publicKey.encrypt(TEST_ENCRYPT_MESSAGE)

      deserializedDecrypted = deserialized.privateKey.decrypt(keypairEncrypted)
      keypairDecrypted      = keypair.privateKey.decrypt(deserializedEncrypted)

      expect(deserializedDecrypted).toBe(TEST_ENCRYPT_MESSAGE)
      expect(keypairDecrypted).toBe(TEST_ENCRYPT_MESSAGE)
