define [
  'require'
  'forge'
  'kryptnostic.cypher'
  'kryptnostic.aes-crypto-service'
  'kryptnostic.block-encryption-service'
  'kryptnostic.hash-function'
], (require) ->

  AesCryptoService       = require 'kryptnostic.aes-crypto-service'
  BlockEncryptionService = require 'kryptnostic.block-encryption-service'
  Cypher                 = require 'kryptnostic.cypher'
  HashFunction           = require 'kryptnostic.hash-function'

  { cryptoService, blockEncryption } = {}

  KEY = 'abcdefghijklmnop'

  beforeEach ->
    cryptoService   = new AesCryptoService( Cypher.AES_GCM_128, KEY )
    blockEncryption = new BlockEncryptionService()

  describe 'BlockEncryptionService', ->

    describe '#encrypt', ->

      it 'should throw on unknown chunk type Date', ->
        chunk = new Date()
        expect( -> blockEncryption.encrypt([chunk], cryptoService) ).toThrow()

      it 'should throw on unknown chunk type Object', ->
        chunk = new Object()
        expect( -> blockEncryption.encrypt([chunk], cryptoService) ).toThrow()

      it 'should return instances of EncryptedBlock', ->
        chunk  = 'test'
        blocks = blockEncryption.encrypt([chunk], cryptoService)

        expect(_.first(blocks).constructor.name).toBe('EncryptedBlock')

      it 'should produce a correct verify hash', ->
        chunks = ['chunk1', 'chunk2']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(2)

        for block in blocks
          expect(block.verify).toBe(HashFunction.SHA_256(block.block.contents))

      it 'should correctly mark the last block', ->
        chunks = ['chunk1', 'chunk2']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(2)
        expect(_.first(blocks).last).toBe(false)
        expect(_.last(blocks).last).toBe(true)

      it 'should record zero-indexed indices of blocks', ->
        chunks = ['chunk1', 'chunk2']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(2)
        expect(_.first(blocks).index).toBe(0)
        expect(_.last(blocks).index).toBe(1)

      it 'should timestamp the block', ->
        chunks = ['test']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(1)
        expect(_.first(blocks).timeCreated).toBeDefined()
        expect(!!_.first(blocks).timeCreated).toBe(true)

      it 'should product contents which are an instance of BlockCiphertext', ->
        chunks = ['test']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(1)
        expect(_.first(blocks).block.constructor.name).toBe('BlockCiphertext')

      it 'should map class name to encrypted value of Java implementation', ->
        chunks = ['test']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(1)
        expect(_.first(blocks).name.constructor.name).toBe('BlockCiphertext')
        expect(_.first(blocks).name.iv).toBeDefined()
        expect(_.first(blocks).name.contents).toBeDefined()
        expect(_.first(blocks).name.salt).toBeDefined()

      it 'should record strategy corresponding to a Java chunking strategy', ->
        chunks = ['test']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blocks.length).toBe(1)
        expect(_.first(blocks).strategy).toEqual({
          '@class': 'com.kryptnostic.kodex.v1.serialization.crypto.DefaultChunkingStrategy'
        })

    describe '#decrypt', ->

      it 'should decrypt a set of self-encrypted blocks', ->
        chunks = ['foo', 'bar', 'test']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        expect(blockEncryption.decrypt(blocks, cryptoService)).toEqual(chunks)

      it 'should throw if block corruption exists', ->
        chunks = ['foo', 'bar', 'test']
        blocks = blockEncryption.encrypt(chunks, cryptoService)

        corruptedBlocks                 = _.cloneDeep(blocks)
        _.first(corruptedBlocks).verify = 'XlCIVydEPWqVfcYYh6ZIF1D6bL/IBVaduN+uj4/mtIo='

        expect( -> blockEncryption.decrypt(corruptedBlocks, cryptoService) ).toThrow()
