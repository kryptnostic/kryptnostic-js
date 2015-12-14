define 'kryptnostic.schema.create-object-request', [], ->

  SCHEMA = {
    properties: {
      type : {
        type       : 'string'
        required   : true
        allowEmpty : false
      }
      parentObjectId : {
        type       : 'string'
        required   : false
        allowEmpty : false
      }
      id : {
        type       : 'string'
        required   : false
        allowEmpty : false
      }
      inheritOwnership : {
        type       : 'boolean'
        required   : false
        allowEmpty : false
      }
      inheritCryptoService : {
        type       : 'boolean'
        required   : false
        allowEmpty : false
      }
      locked : {
        type       : 'boolean'
        required   : false
        allowEmpty : false
      }
    }
  }

  return SCHEMA
