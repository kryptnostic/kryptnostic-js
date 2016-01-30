define 'kryptnostic.block-encryption-service', [
  'require'
  'lodash'
  'forge'
  'kryptnostic.encrypted-block'
  'kryptnostic.logger'
], (require) ->
  'use strict'

  _              = require 'lodash'
  forge          = require 'forge'
  EncryptedBlock = require 'kryptnostic.encrypted-block'
  Logger         = require 'kryptnostic.logger'

  log = Logger.get('BlockEncryptionService')

  TYPE_MAPPINGS = {
    'String' : 'java.lang.String'
  }

  DEFAULT_STRATEGY = {
    '@class': 'com.kryptnostic.kodex.v1.serialization.crypto.DefaultChunkingStrategy'
  }

  verifyHashFunction = (data) ->
    return btoa(forge.md.sha256.create().update(atob(data)).digest().data)

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
        unless chunk.constructor.name in _.keys(TYPE_MAPPINGS)
          throw new Error 'unsupported chunk type'

        className   = chunk.constructor.name
        mappedClass = TYPE_MAPPINGS[className]
        block       = cryptoService.encrypt(chunk)
        name        = cryptoService.encrypt(mappedClass)
        verify      = verifyHashFunction(block.contents)
        last        = (index == chunks.length - 1)
        strategy    = DEFAULT_STRATEGY
        timeCreated = new Date().getTime()

        block = { block, name, verify, index, last, strategy, timeCreated }
        log.info('created block')
        return new EncryptedBlock(block)

    # convert encrypted blocks into string data chunks
    decrypt : (blocks, cryptoService) ->
      return blocks.map ({ block, verify }) ->
        computed = verifyHashFunction(block.contents)
        unless verify is computed
          log.info('block verify mismatch', { verify, computed })
          throw new Error('cannot decrypt block because verify of block contents does not match.')
        decrypted = cryptoService.decrypt(block)
        return decrypted

  return BlockEncryptionService
