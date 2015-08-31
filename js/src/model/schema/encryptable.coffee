define 'kryptnostic.schema.encryptable', [
  'require'
  'kryptnostic.schema.encrypted-block'
  'kryptnostic.schema.block-ciphertext'
], ->

  ENCRYPTED_BLOCK_SCHEMA  = require 'kryptnostic.schema.encryptable'
  BLOCK_CIPHERTEXT_SCHEMA = require 'kryptnostic.schema.block-ciphertext'

  return {
    properties : {

      data : {
        description : 'list of encrypted blocks'
        type        : 'array'
        required    : true
        allowEmpty  : false
        items       : ENCRYPTED_BLOCK_SCHEMA
      },
      key : {
        description : 'id of the cryptoservice for decrypting this object'
        type        : 'string'
        required    : true
        allowEmpty  : false
      }
      strategy : {
        type     : 'object'
        required : true
      }
      name : _.extend({}, BLOCK_CIPHERTEXT_SCHEMA, description: 'encrypted class name')

    }
  }
