define 'kryptnostic.encrypted-block', [
  'require'
  'lodash'
  'kryptnostic.schema.validator'
  'kryptnostic.schema.encrypted-block'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'kryptnostic.schema.validator'
  SCHEMA    = require 'kryptnostic.schema.encrypted-block'

  #
  # Represents a block of encrypted data stored as part of a kryptnostic object.
  # Author: rbuckheit
  #
  class EncryptedBlock

    constructor : (raw) ->
      _.extend(this, raw)
      @validate()

    validate : ->
      validator.validate(this, EncryptedBlock, SCHEMA)

  return EncryptedBlock
