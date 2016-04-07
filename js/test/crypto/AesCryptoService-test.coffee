define [
  'require',
  'forge',
  'sinon',
  'kryptnostic.aes-crypto-service',
  'kryptnostic.binary-utils'
  'kryptnostic.cypher'
], (require) ->

  # libraries
  forge = require 'forge'
  sinon = require 'sinon'

  # kryptnostic
  AesCryptoService = require 'kryptnostic.aes-crypto-service'
  Cypher = require 'kryptnostic.cypher'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'

  #
  # constants
  #

  EMPTY_STRING = ''
  GET_RANDOM_BYTES_12 = 12 # 96 / 8
  GET_RANDOM_BYTES_16 = 16 # 128 / 8

  #
  # mock data
  #

  MOCK_AES_CTR_128_KEY_AS_BASE64 = 'WgA4WGdgvmPwdMukW0ot+Q=='
  MOCK_AES_CTR_128_KEY = atob(MOCK_AES_CTR_128_KEY_AS_BASE64)

  MOCK_AES_GCM_256_KEY_AS_BASE64 = 'h98aH2Pzo4Tf09dKb/izZ2gbGFvJZjVh79vQnjj3HeU='
  MOCK_AES_GCM_256_KEY = atob(MOCK_AES_GCM_256_KEY_AS_BASE64)

  MOCK_IV_96_AS_BASE64 = '96G3gwlt831ChB/q'
  MOCK_IV_96 = atob(MOCK_IV_96_AS_BASE64)

  MOCK_IV_128_AS_BASE64 = 'NcPueGQak7uM0VoAcbn+kw=='
  MOCK_IV_128 = atob(MOCK_IV_128_AS_BASE64)

  MOCK_DATA = [
    {
      PLAINTEXT: 'The Unforgiven',
      CIPHERTEXT: {
        AES_CTR_128: {
          iv: MOCK_IV_128_AS_BASE64,
          salt: '',
          contents: 'KS3FjmKkaGNOrbhnbsA=',
          tag: 'DzTZtLRUr8QGdsuwKmAeSacqbF7owDJmcsx7Eq3Oufw='
        },
        AES_GCM_256: {
          iv: MOCK_IV_96_AS_BASE64,
          salt: '',
          contents: '/My9PVhY+sjQvnd6+gU=',
          tag: 'T3lx5qd1evCP4gq6t492QQ=='
        }
      }
    },
    {
      PLAINTEXT: 'What Ive felt. What Ive known. Never shined through in what Ive shown.',
      CIPHERTEXT: {
        AES_CTR_128: {
          iv: MOCK_IV_128_AS_BASE64,
          salt: '',
          contents: 'Ki3B2heDeGkcrLR9f4CLi6ZCyItariB6JK+RHcA1fo9o5P4UGPNQiKnj+ZST0hYMRECvDxjsTp+2Lo2qvLjiwtD1bfbuXQ==',
          tag: 'jRKRvFQBdbkiuECJhmbHcYClz8jzhc0heEDxFGRAmhU='
        },
        AES_GCM_256: {
          iv: MOCK_IV_96_AS_BASE64,
          salt: '',
          contents: '/8y5aS1/6sKCv3tg60UV4JJFpnSV0QRj3wUku7XQ0ngmMda3zu8d6C3X6WO+Yepj89KDjHWe1WwY9kdIhc/tjUGY+2rHuQ==',
          tag: 'jwOs3T8WcL5u0fNnHh1XfA=='
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
      aesCryptoService3 = new AesCryptoService(Cypher.AES_GCM_256)
      aesCryptoService4 = new AesCryptoService(Cypher.AES_GCM_256)

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

      aesCryptoService2 = new AesCryptoService(Cypher.AES_GCM_256)
      expect(aesCryptoService2.cypher).toEqual(Cypher.AES_GCM_256)
      blockCipherText2 = aesCryptoService2.encrypt('plaintext')
      expect(aesCryptoService2.cypher).toEqual(Cypher.AES_GCM_256)
      aesCryptoService2.decrypt(blockCipherText2)
      expect(aesCryptoService2.cypher).toEqual(Cypher.AES_GCM_256)

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
        aesCryptoService = new AesCryptoService(Cypher.AES_CTR_128, MOCK_AES_CTR_128_KEY)
        forgeGetBytesSyncStub
          .withArgs(GET_RANDOM_BYTES_16)
          .returns(MOCK_IV_128)

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

    describe 'AES_GCM_256', ->

      forgeGetBytesSyncStub = null

      beforeAll ->
        forgeGetBytesSyncStub = sinon.stub(forge.random, 'getBytesSync')

      afterAll ->
        forge.random.getBytesSync.restore()

      beforeEach ->
        aesCryptoService = new AesCryptoService(Cypher.AES_GCM_256, MOCK_AES_GCM_256_KEY)
        forgeGetBytesSyncStub
          .withArgs(GET_RANDOM_BYTES_12)
          .returns(MOCK_IV_96)

      afterEach ->
        forgeGetBytesSyncStub.reset()

      it 'single AES block - encrypt()', ->

        plaintext = MOCK_DATA[0].PLAINTEXT
        resultBCT = aesCryptoService.encrypt(plaintext)

        expectedBCT = MOCK_DATA[0].CIPHERTEXT.AES_GCM_256
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'single AES block - encryptUint8Array()', ->

        plaintext = MOCK_DATA[0].PLAINTEXT
        plaintextAsUint8 = BinaryUtils.stringToUint8(plaintext)
        resultBCT = aesCryptoService.encryptUint8Array(plaintextAsUint8)

        expectedBCT = MOCK_DATA[0].CIPHERTEXT.AES_GCM_256
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'single AES block - decrypt()', ->

        blockCipherText = MOCK_DATA[0].CIPHERTEXT.AES_GCM_256
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'single AES block - decryptToUint8Array()', ->

        blockCipherText = MOCK_DATA[0].CIPHERTEXT.AES_GCM_256
        plaintextAsUint8 = aesCryptoService.decryptToUint8Array(blockCipherText)

        expectedPlaintext = MOCK_DATA[0].PLAINTEXT
        expectedPlaintextAsUint8 = BinaryUtils.stringToUint8(expectedPlaintext)
        expect(plaintextAsUint8).toEqual(expectedPlaintextAsUint8)

      it 'multiple AES blocks - encrypt()', ->

        plaintext = MOCK_DATA[1].PLAINTEXT
        resultBCT = aesCryptoService.encrypt(plaintext)

        expectedBCT = MOCK_DATA[1].CIPHERTEXT.AES_GCM_256
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'multiple AES blocks - encryptUint8Array()', ->

        plaintext = MOCK_DATA[1].PLAINTEXT
        plaintextAsUint8 = BinaryUtils.stringToUint8(plaintext)
        resultBCT = aesCryptoService.encryptUint8Array(plaintextAsUint8)

        expectedBCT = MOCK_DATA[1].CIPHERTEXT.AES_GCM_256
        expect(resultBCT).toEqualBlockCipherText(expectedBCT)

      it 'multiple AES blocks - decrypt()', ->

        blockCipherText = MOCK_DATA[1].CIPHERTEXT.AES_GCM_256
        plaintext = aesCryptoService.decrypt(blockCipherText)

        expectedPlaintext = MOCK_DATA[1].PLAINTEXT
        expect(plaintext).toEqual(expectedPlaintext)

      it 'multiple AES blocks - decryptToUint8Array()', ->

        blockCipherText = MOCK_DATA[1].CIPHERTEXT.AES_GCM_256
        plaintextAsUint8 = aesCryptoService.decryptToUint8Array(blockCipherText)

        expectedPlaintext = MOCK_DATA[1].PLAINTEXT
        expectedPlaintextAsUint8 = BinaryUtils.stringToUint8(expectedPlaintext)
        expect(plaintextAsUint8).toEqual(expectedPlaintextAsUint8)

      it 'missing or empty or incorrect tag is not ok', ->

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_GCM_256)
        delete blockCipherText.tag

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_GCM_256)
        blockCipherText.tag = ''

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()

        blockCipherText = _.cloneDeep(MOCK_DATA[0].CIPHERTEXT.AES_GCM_256)
        blockCipherText.tag = 'invalid'

        expect( ->
          aesCryptoService.decrypt(blockCipherText)
        ).toThrow()
