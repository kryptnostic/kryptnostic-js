define 'soteria.block-encryption-service', [
  'require'
  'lodash'
  'forge.min'
  'soteria.encrypted-block'
  'soteria.hash-function'
], (require) ->
  'use strict'

  _              = require 'lodash'
  forge          = require 'forge.min'
  EncryptedBlock = require 'soteria.encrypted-block'
  HashFunction   = require 'soteria.hash-function'

  VERIFY_HASH_FUNCTION = HashFunction.SHA_256

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

    # convert raw data string chunks into encrypted blocks
    encrypt: (chunks, cryptoService) ->
      return chunks.map (chunk, index) ->
        className   = chunk.constructor.name
        block       = cryptoService.encrypt(chunk)
        name        = cryptoService.encrypt(className)
        verify      = VERIFY_HASH_FUNCTION(block.contents)
        last        = (index == chunks.length - 1)
        strategy    = {'@class': 'com.kryptnostic.kodex.v1.serialization.crypto.DefaultChunkingStrategy'}
        timeCreated = new Date().getTime()

        block = { block, name, verify, index, last, strategy, timeCreated }
        log('created raw block', block)
        return new EncryptedBlock(block)

    # convert encrypted blocks into string data chunks
    decrypt : (chunks, cryptoService) ->
      return chunks.map ({block, verify}) ->
        computed = VERIFY_HASH_FUNCTION(block.contents)
        unless verify is computed
          log('block verify mismatch', {verify, computed})
          throw new Error('cannot decrypt block because verify of block contents does not match.')
        decrypted = cryptoService.decrypt(block)
        log('decrypted block', decrypted)
        return decrypted

  return BlockEncryptionService