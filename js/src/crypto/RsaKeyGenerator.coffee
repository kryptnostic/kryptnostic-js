define 'kryptnostic.rsa-key-generator', [
  'require'
  'forge'
  'kryptnostic.logger'
], (require) ->

  Forge  = require 'forge'
  Logger = require 'kryptnostic.logger'

  log = Logger.get('RsaKeyGenerator')

  RSA_KEY_SIZE = 4096
  EXPONENT     = 0x10001

  class RsaKeyGenerator

    generate: (params) ->
      Forge.rsa.generateKeyPair(params)

    generateKeypair: ->
      params = { bits: RSA_KEY_SIZE, e: EXPONENT }
      log.info('generating keypair', params)
      return @generate(params)

  return RsaKeyGenerator
