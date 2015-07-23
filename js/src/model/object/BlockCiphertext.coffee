define 'kryptnostic.block-ciphertext', [
  'require'
  'lodash'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.block-ciphertext'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'kryptnostic.schema.validator'
  SCHEMA    = require 'kryptnostic.schema.block-ciphertext'

  #
  # Represents a block ciphertext.
  # Author: rbuckheit
  #
  class BlockCiphertext

    constructor : (raw) ->
      _.extend(this, raw)
      @validate()

    validate : ->
      validator.validate(this, BlockCiphertext, SCHEMA)

  return BlockCiphertext
