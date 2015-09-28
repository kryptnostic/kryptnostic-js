define 'kryptnostic.block-ciphertext', [
  'require'
  'lodash'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.block-ciphertext'
], (require) ->
  'use strict'

  # libraries
  _ = require 'lodash'

  # schemas
  SCHEMA = require 'kryptnostic.schema.block-ciphertext'

  # utils
  Validator = require 'kryptnostic.schema.validator'

  class BlockCiphertext

    constructor : (raw) ->
      _.extend(this, raw)
      @validate()

    validate : ->
      Validator.validate(this, BlockCiphertext, SCHEMA)

  return BlockCiphertext
