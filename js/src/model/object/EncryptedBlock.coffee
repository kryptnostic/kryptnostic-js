define 'soteria.encrypted-block', [
  'require'
  'lodash'
  'soteria.schema.validator'
  'soteria.schema.encrypted-block'
], (require) ->
  'use strict'

  _         = require 'lodash'
  validator = require 'soteria.schema.validator'
  SCHEMA    = require 'soteria.schema.encrypted-block'

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
