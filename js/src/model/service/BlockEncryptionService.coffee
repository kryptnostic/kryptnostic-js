define 'soteria.block-encryption-service', [
  'require'
  'lodash'
  'forge.min'
  'soteria.encrypted-block'
], (require) ->
  'use strict'

  _              = require 'lodash'
  forge          = require 'forge.min'
  EncryptedBlock = require 'soteria.encrypted-block'

  VERIFY_HASH_FUNCTION = (data) ->
    return forge.md.sha256.create().update(data).digest().toHex();

  log = (message, args...) =>
    console.info("[BlockEncryptionService] #{message} #{args.map(JSON.stringify)}")

  #
  # Service for encrypting and decrypting blocks of a kryptnostic object,
  # and verifying integrity on encryption and decryption.
  #
  # Author: rbuckheit
  #
  class BlockEncryptionService

    constructor: ->

    encrypt: (chunks, cryptoService) ->
      return chunks.map (chunk, index) ->
        className   = chunk.constructor.name
        block       = cryptoService.encrypt(chunk)
        name        = cryptoService.encrypt(className)
        verify      = VERIFY_HASH_FUNCTION(block.contents)
        last        = (index == chunks.length - 1)
        strategy    = {'@class': 'soteria.chunking.strategy.default'}
        timeCreated = new Date().getTime()

        block = { block, name, verify, index, last, strategy, timeCreated }
        log('created raw block', block)
        return new EncryptedBlock(block)

    # TODO add decrypt function with verify.

  return BlockEncryptionService