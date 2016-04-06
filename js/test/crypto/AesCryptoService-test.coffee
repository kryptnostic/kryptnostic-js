define [
  'require',
  'forge',
  'sinon',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.block-ciphertext',
  'kryptnostic.binary-utils'
  'kryptnostic.crypto-service-marshaller',
  'kryptnostic.cypher',
  'kryptnostic.mock.mock-data-utils',
  'kryptnostic.rsa-crypto-service'
], (require) ->

  # libraries
  forge = require 'forge'
  sinon = require 'sinon'

  # kryptnostic
  AesCryptoService = require 'kryptnostic.aes-crypto-service'
  BlockCiphertext = require 'kryptnostic.block-ciphertext'
  CryptoServiceMarshaller = require 'kryptnostic.crypto-service-marshaller'
  Cypher = require 'kryptnostic.cypher'
  RsaCryptoService = require 'kryptnostic.rsa-crypto-service'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'
  MockDataUtils = require 'kryptnostic.mock.mock-data-utils'

  #
  # constants
  #

  EMPTY_STRING = ''
  AES_BLOCK_SIZE_IN_BYTES = 16

  #
  # mock data
  #

  MOCK_AES_KEY_AS_BASE64 = 'oVnwGOr+KQXdHpfnMGzmrA=='
  MOCK_AES_KEY_BYTES = atob(MOCK_AES_KEY_AS_BASE64)

  MOCK_AES_IV_AS_BASE64 = 'K1T2Tch7ad/rZCMzzk+5IA=='
  MOCK_AES_IV_BYTES = atob(MOCK_AES_IV_AS_BASE64)

  MOCK_DATA = [
    {
      PLAINTEXT: 'The Unforgiven',
      CIPHERTEXT: {
        AES_CTR_128: {
          iv: MOCK_AES_IV_AS_BASE64,
          salt: '',
          contents: 'TqY2Bki3oPgxXugPNgY=',
          tag: 'AKDk/PrlMnbNaVGEsUxyZsrvqJZSVl5JkY6m7hI2p8U='
        },
        AES_GCM_128: {
          iv: MOCK_AES_IV_AS_BASE64,
          salt: '',
          contents: 'ycjc4qObTVmZz6BbTF8=',
          tag: 'b1vKlrktzLltiS/BPHwAXg=='
        }
      }
    },
    {
      PLAINTEXT: 'What Ive felt. What Ive known. Never shined through in what Ive shown.',
      CIPHERTEXT: {
        AES_CTR_128: {
          iv: MOCK_AES_IV_AS_BASE64,
          salt: '',
          contents: 'TaYyUj2QsPJjX+QVJ0ZRyx46DCWQ/VdZaecQrjIWy5dpTydNjdmIfYZn2/ieGtqDvGz+4ZPkIKCWX8yJoXq5xh/px50w5g==',
          tag: 'vLpqLNi/dbxTCUikF2w2waeRxCu/rSjDUQsFApWWKpY='
        },
        AES_GCM_128: {
          iv: MOCK_AES_IV_AS_BASE64,
          salt: '',
          contents: 'ysjYtta8XVPLzqxBXR8nwjVv4hPHdQGKYL5WFzglTziTuRXtjqpN6WpA/90TegjZZP1dEX9OyIAIYFm13NfbvC0MHOZHOw==',
          tag: 'ZRnG1lkAi85RWH4Wvf7jpg=='
        }
      }
    }
  ]

  aesCryptoService = null

  describe 'AesCryptoService', ->

    beforeEach ->
      jasmine.addMatchers toEqualBlockCipherText: ->
        {
          compare: (givenBCT, expectedBCT) ->

            ivIsEqual = givenBCT.iv == expectedBCT.iv
            saltIsEqual = givenBCT.salt == expectedBCT.salt
            contentsIsEqual = givenBCT.contents == expectedBCT.contents
            tagIsEqual = givenBCT.tag == expectedBCT.tag

            blockCipherTextIsEqual = ivIsEqual and saltIsEqual and contentsIsEqual and tagIsEqual

            result =
              pass    : blockCipherTextIsEqual
              message : undefined

            if !result.pass
              if !ivIsEqual
                result.message = 'BlockCipherText iv property does not match. ' +
                  'expected ' + givenBCT.iv + ', but got ' + expectedBCT.iv
              else if !saltIsEqual
                result.message = 'BlockCipherText salt property does not match. ' +
                  'expected ' + givenBCT.salt + ', but got ' + expectedBCT.salt
              else if !contentsIsEqual
                result.message = 'BlockCipherText contents property does not match. ' +
                  'expected ' + givenBCT.contents + ', but got ' + expectedBCT.contents
              else if !tagIsEqual
                result.message = 'BlockCipherText tag property does not match. ' +
                  'expected ' + givenBCT.tag + ', but got ' + expectedBCT.tag
              else
                result.message = 'given BlockCipherText does not match expected BlockCipherText'

            return result
        }

    it 'should have a static field for the class name', ->

      expect(AesCryptoService._CLASS_NAME).toBeDefined()
      expect(AesCryptoService._CLASS_NAME).toEqual('AesCryptoService')

      aesCryptoService = new AesCryptoService(Cypher.AES_CTR_128)
      expect(aesCryptoService._CLASS_NAME).toBeDefined()
      expect(aesCryptoService._CLASS_NAME).toEqual('AesCryptoService')

    it 'should generate a random AES key if a key is not given', ->

      aesCryptoService1 = new AesCryptoService(Cypher.AES_CTR_128)
      aesCryptoService2 = new AesCryptoService(Cypher.AES_CTR_128)
      aesCryptoService3 = new AesCryptoService(Cypher.AES_GCM_128)
      aesCryptoService4 = new AesCryptoService(Cypher.AES_GCM_128)

      expect(aesCryptoService1.key).not.toEqual(aesCryptoService2.key)
      expect(aesCryptoService3.key).not.toEqual(aesCryptoService4.key)
      expect(aesCryptoService1.key).not.toEqual(aesCryptoService3.key)
      expect(aesCryptoService2.key).not.toEqual(aesCryptoService4.key)

    it 'should store and never change the cypher', ->

      aesCryptoService1 = new AesCryptoService(Cypher.AES_CTR_128)
      expect(aesCryptoService1.cypher).toEqual(Cypher.AES_CTR_128)
      blockCipherText1 = aesCryptoService1.encrypt('plaintext')
      expect(aesCryptoService1.cypher).toEqual(Cypher.AES_CTR_128)
      aesCryptoService1.decrypt(blockCipherText1)
      expect(aesCryptoService1.cypher).toEqual(Cypher.AES_CTR_128)

      aesCryptoService2 = new AesCryptoService(Cypher.AES_GCM_128)
      expect(aesCryptoService2.cypher).toEqual(Cypher.AES_GCM_128)
      blockCipherText2 = aesCryptoService2.encrypt('plaintext')
      expect(aesCryptoService2.cypher).toEqual(Cypher.AES_GCM_128)
      aesCryptoService2.decrypt(blockCipherText2)
      expect(aesCryptoService2.cypher).toEqual(Cypher.AES_GCM_128)

    describe 'AES_CTR_128', ->

      forgeHmacSpy = null
      forgeGetBytesSyncStub = null

      beforeAll ->
        forgeHmacSpy = sinon.spy(forge.hmac, 'create')
        forgeGetBytesSyncStub = sinon.stub(forge.random, 'getBytesSync')

      afterAll ->
        forge.hmac.create.restore()
        forge.random.getBytesSync.restore()

      beforeEach ->
        aesCryptoService = new AesCryptoService(Cypher.AES_CTR_128, MOCK_AES_KEY_BYTES)
        forgeGetBytesSyncStub
          .withArgs(AES_BLOCK_SIZE_IN_BYTES)
          .returns(MOCK_AES_IV_BYTES)

      afterEach ->
        forgeHmacSpy.reset()
        forgeGetBytesSyncStub.reset()

      it 'single AES block - encrypt()', ->

        plaintext = MOCK_DATA[0].PLAINTEXT
        resultBCT = aesCryptoService.encrypt(plaintext)

        expectedBCT = MOCK_DATA[0].CIPHERTEXT.AES_CTR_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)
        sinon.assert.calledOnce(forgeHmacSpy)

      it 'single AES block - encryptUint8Array()', ->

        plaintext = MOCK_DATA[0].PLAINTEXT
        plaintextAsUint8 = BinaryUtils.stringToUint8(plaintext)
        resultBCT = aesCryptoService.encryptUint8Array(plaintextAsUint8)

        expectedBCT = MOCK_DATA[0].CIPHERTEXT.AES_CTR_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)
        sinon.assert.calledOnce(forgeHmacSpy)

      it 'single AES block - decrypt()', ->

        blockCipherText = MOCK_DATA[0].CIPHERTEXT.AES_CTR_128
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'single AES block - decryptToUint8Array()', ->

        blockCipherText = MOCK_DATA[0].CIPHERTEXT.AES_CTR_128
        plaintextAsUint8 = aesCryptoService.decryptToUint8Array(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expectedPlaintextAsUint8 = BinaryUtils.stringToUint8(expectedPlaintext)
        expect(plaintextAsUint8).toEqual(expectedPlaintextAsUint8)

      it 'multiple AES blocks - encrypt()', ->

        plaintext = MOCK_DATA[1].PLAINTEXT
        resultBCT = aesCryptoService.encrypt(plaintext)

        expectedBCT = MOCK_DATA[1].CIPHERTEXT.AES_CTR_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)
        sinon.assert.calledOnce(forgeHmacSpy)

      it 'multiple AES blocks - encryptUint8Array()', ->

        plaintext = MOCK_DATA[1].PLAINTEXT
        plaintextAsUint8 = BinaryUtils.stringToUint8(plaintext)
        resultBCT = aesCryptoService.encryptUint8Array(plaintextAsUint8)

        expectedBCT = MOCK_DATA[1].CIPHERTEXT.AES_CTR_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)
        sinon.assert.calledOnce(forgeHmacSpy)

      it 'multiple AES blocks - decrypt()', ->

        blockCipherText = MOCK_DATA[1].CIPHERTEXT.AES_CTR_128
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[1].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'multiple AES blocks - decryptToUint8Array()', ->

        blockCipherText = MOCK_DATA[1].CIPHERTEXT.AES_CTR_128
        plaintextAsUint8 = aesCryptoService.decryptToUint8Array(blockCipherText)

        expectedPlaintext = MOCK_DATA[1].PLAINTEXT
        expectedPlaintextAsUint8 = BinaryUtils.stringToUint8(expectedPlaintext)
        expect(plaintextAsUint8).toEqual(expectedPlaintextAsUint8)

      it 'missing or empty tag is ok', ->

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_CTR_128)
        delete blockCipherText.tag
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_CTR_128)
        blockCipherText.tag = ''
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'existing but incorrect tag is not ok', ->

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_CTR_128)
        blockCipherText.tag = 'invalid'

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()

    describe 'AES_GCM_128', ->

      forgeGetBytesSyncStub = null

      beforeAll ->
        forgeGetBytesSyncStub = sinon.stub(forge.random, 'getBytesSync')

      afterAll ->
        forge.random.getBytesSync.restore()

      beforeEach ->
        aesCryptoService = new AesCryptoService(Cypher.AES_GCM_128, MOCK_AES_KEY_BYTES)
        forgeGetBytesSyncStub
          .withArgs(AES_BLOCK_SIZE_IN_BYTES)
          .returns(MOCK_AES_IV_BYTES)

      afterEach ->
        forgeGetBytesSyncStub.reset()

      it 'single AES block - encrypt()', ->

        plaintext = MOCK_DATA[0].PLAINTEXT
        resultBCT = aesCryptoService.encrypt(plaintext)

        expectedBCT = MOCK_DATA[0].CIPHERTEXT.AES_GCM_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'single AES block - encryptUint8Array()', ->

        plaintext = MOCK_DATA[0].PLAINTEXT
        plaintextAsUint8 = BinaryUtils.stringToUint8(plaintext)
        resultBCT = aesCryptoService.encryptUint8Array(plaintextAsUint8)

        expectedBCT = MOCK_DATA[0].CIPHERTEXT.AES_GCM_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'single AES block - decrypt()', ->

        blockCipherText = MOCK_DATA[0].CIPHERTEXT.AES_GCM_128
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'single AES block - decryptToUint8Array()', ->

        blockCipherText = MOCK_DATA[0].CIPHERTEXT.AES_GCM_128
        plaintextAsUint8 = aesCryptoService.decryptToUint8Array(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expectedPlaintextAsUint8 = BinaryUtils.stringToUint8(expectedPlaintext)
        expect(plaintextAsUint8).toEqual(expectedPlaintextAsUint8)

      it 'multiple AES blocks - encrypt()', ->

        plaintext = MOCK_DATA[1].PLAINTEXT
        resultBCT = aesCryptoService.encrypt(plaintext)

        expectedBCT = MOCK_DATA[1].CIPHERTEXT.AES_GCM_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'multiple AES blocks - encryptUint8Array()', ->

        plaintext = MOCK_DATA[1].PLAINTEXT
        plaintextAsUint8 = BinaryUtils.stringToUint8(plaintext)
        resultBCT = aesCryptoService.encryptUint8Array(plaintextAsUint8)

        expectedBCT = MOCK_DATA[1].CIPHERTEXT.AES_GCM_128
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'multiple AES blocks - decrypt()', ->

        blockCipherText = MOCK_DATA[1].CIPHERTEXT.AES_GCM_128
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[1].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'multiple AES blocks - decryptToUint8Array()', ->

        blockCipherText = MOCK_DATA[1].CIPHERTEXT.AES_GCM_128
        plaintextAsUint8 = aesCryptoService.decryptToUint8Array(blockCipherText)

        expectedPlaintext = MOCK_DATA[1].PLAINTEXT
        expectedPlaintextAsUint8 = BinaryUtils.stringToUint8(expectedPlaintext)
        expect(plaintextAsUint8).toEqual(expectedPlaintextAsUint8)

      it 'missing or empty or incorrect tag is not ok', ->

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_GCM_128)
        delete blockCipherText.tag

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_GCM_128)
        blockCipherText.tag = ''

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_GCM_128)
        blockCipherText.tag = 'invalid'

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()

    # describe '#encrypt', ->
    #
    #   it 'should produce a block ciphertext', ->
    #     plaintext       = 'convert to block ciphertext'
    #     blockCiphertext = cryptoService.encrypt(plaintext)
    #     expect(blockCiphertext.constructor.name).toBe('BlockCiphertext')
    #     expect(blockCiphertext.iv).toBeDefined()
    #     expect(blockCiphertext.contents).toBeDefined()
    #
    #   it 'should produce an initialization vector in base 64 with a binary length of 16 bytes', ->
    #     plaintext       = 'convert to block ciphertext'
    #     blockCiphertext = cryptoService.encrypt(plaintext)
    #     byteCount       = forge.util.createBuffer(atob(blockCiphertext.iv), 'raw').length()
    #     expect(byteCount).toBe(16)
    #
