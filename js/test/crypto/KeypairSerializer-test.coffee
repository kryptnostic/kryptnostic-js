define [
  'require'
  'forge'
  'soteria.keypair-serializer'
], (require) ->

  Forge             = require 'forge'
  KeypairSerializer = require 'soteria.keypair-serializer'

  PUBLIC_KEY_COMPARE_FIELDS  = ['n', 'e']
  PRIVATE_KEY_COMPARE_FIELDS = ['n', 'e', 'd', 'p', 'q', 'dP', 'dQ', 'qInv']

  describe 'KeypairSerializer', ->

    it 'should serialize and hydrate a keypair', ->
      keypair      = Forge.rsa.generateKeyPair({bits: 2048, e: 0x10001})
      serialized   = KeypairSerializer.serialize(keypair)
      deserialized = KeypairSerializer.hydrate(serialized)

      PUBLIC_KEY_COMPARE_FIELDS.forEach (field) ->
        expect(deserialized.publicKey[field]).toEqual(keypair.publicKey[field])
      PRIVATE_KEY_COMPARE_FIELDS.forEach (field) ->
        window.console && console.info('field',field)
        window.console && console.info(JSON.stringify(deserialized.privateKey[field]))
        expect(deserialized.privateKey[field]).toEqual(keypair.privateKey[field])

    describe '#serialize', ->

      it 'should serialize to a known value', ->

    describe '#hydrate', ->

      it 'should hydrate a known keypair', ->

