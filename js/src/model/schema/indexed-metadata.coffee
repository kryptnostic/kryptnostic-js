define 'kryptnostic.schema.indexed-metadata', [
  'require'
  'kryptnostic.schema.encryptable'
], (require) ->

  ENCRYPTABLE_SCHEMA = require 'kryptnostic.schema.encryptable'

  SCHEMA = {
    properties : {
      key : {
        description : 'the indexed search key for this term'
        type        : 'string'
        required    : true
        allowEmpty  : false
      },
      id : {
        description : 'the object id which the term came from',
        type        : 'string'
        required    : true
        allowEmpty  : false
      }
      data :
        _.extend({}, ENCRYPTABLE_SCHEMA, description: 'the encrypted metadata content' )
    }
  }

  return SCHEMA
