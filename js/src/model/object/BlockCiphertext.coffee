define 'soteria.block-ciphertext', [
  'require'
  'lodash'
  'soteria.schema.validator'
  'soteria.schema.block-ciphertext'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'soteria.schema.validator'
  SCHEMA    = require 'soteria.schema.block-ciphertext'

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
