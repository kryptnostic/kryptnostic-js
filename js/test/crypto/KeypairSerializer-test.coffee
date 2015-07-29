define [
  'require'
  'forge'
  'kryptnostic.keypair-serializer'
], (require) ->

  Forge             = require 'forge'
  KeypairSerializer = require 'kryptnostic.keypair-serializer'

  TEST_ENCRYPT_MESSAGE = 'foo'

  { keypair } = {}

  beforeEach ->
    keypair = Forge.rsa.generateKeyPair({ bits: 128, e: 0x10001 })


  describe 'KeypairSerializer', ->

    it 'should serialize and deserialize a keypair which can still decrypt messages', ->
      deserialized          = KeypairSerializer.hydrate(KeypairSerializer.serialize(keypair))

      keypairEncrypted      = keypair.publicKey.encrypt(TEST_ENCRYPT_MESSAGE)
      deserializedDecrypted = deserialized.privateKey.decrypt(keypairEncrypted)

      expect(deserializedDecrypted).toBe(TEST_ENCRYPT_MESSAGE)

    it 'should serialize and deserialize a keypair which can still encrypt messages', ->
      deserialized          = KeypairSerializer.hydrate(KeypairSerializer.serialize(keypair))

      deserializedEncrypted = deserialized.publicKey.encrypt(TEST_ENCRYPT_MESSAGE)
      keypairDecrypted      = keypair.privateKey.decrypt(deserializedEncrypted)

      expect(keypairDecrypted).toBe(TEST_ENCRYPT_MESSAGE)
