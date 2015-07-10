define 'soteria.schema.block-ciphertext', [], ->

  SCHEMA = {
    type: 'object'
    properties: {
      iv       : { type: 'string', required: true, allowEmpty: false }
      salt     : { type: 'string', required: true, allowEmpty: true }
      contents : { type: 'string', required: true, allowEmpty: false }
    }
  }

  return SCHEMA
