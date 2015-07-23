define 'kryptnostic.schema.encrypted-block', [
  'require'
  'kryptnostic.schema.block-ciphertext'
], (require) ->

  BLOCK_CIPHERTEXT_SCHEMA = require('kryptnostic.schema.block-ciphertext')

  SCHEMA = {
    type       : 'object'
    properties : {
      block : BLOCK_CIPHERTEXT_SCHEMA
      name  : BLOCK_CIPHERTEXT_SCHEMA
      verify: {
        type       : 'string'
        required   : true
        allowEmpty : false
      }
      index: {
        type     : 'number'
        required : true
        minimum  : 0
      }
      last : {
        type     : 'boolean'
        required : true
      }
      strategy : {
        type     : 'object'
        required : true
        properties: {
          '@class': {
            type       : 'string'
            required   : true
            allowEmpty : false
          }
        }
      }
      timeCreated: {
        type     : 'number'
        required : true
      }
    }
  }

  return SCHEMA

