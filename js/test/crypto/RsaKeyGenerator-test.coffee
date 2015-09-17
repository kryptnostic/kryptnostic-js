define [
  'require'
  'sinon'
  'kryptnostic.rsa-key-generator'
], (require) ->

  sinon           = require 'sinon'
  RsaKeyGenerator = require 'kryptnostic.rsa-key-generator'

  { rsaKeyGenerator, params } = {}

  beforeEach ->
    rsaKeyGenerator = new RsaKeyGenerator()
    sinon.stub(rsaKeyGenerator, 'forgeGenerate', (_params) -> params = _params)

  afterEach ->
    rsaKeyGenerator.forgeGenerate.restore()

  describe 'RsaKeyGenerator', ->

    describe '#generateKeypair', ->

      it 'should generate an RSA keypair of 4096 bits', ->
        rsaKeyGenerator.generateKeypair()
        expect(params.bits).toBe(4096)

      it 'should use an exponent of 65537', ->
        rsaKeyGenerator.generateKeypair()
        expect(params.e).toBe(0x10001)
        expect(params.e).toBe(65537)
