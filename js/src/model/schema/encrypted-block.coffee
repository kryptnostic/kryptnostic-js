define 'soteria.schema.encrypted-block', [], (require) ->

  BLOCK_CIPHERTEXT_SCHEMA = {
    type: 'object'
    properties: {
      iv       : { type: 'string', required: true, allowEmpty: false }
      salt     : { type: 'string', required: true, allowEmpty: true }
      contents : { type: 'string', required: true, allowEmpty: false }
    }
  }

  SCHEMA = {
    properties: {
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

