define 'kryptnostic.schema.sharing-request', [], ->

  SCHEMA = {
    properties: {
      id : {
        description : 'id of the object being shared'
        type        : 'string'
        required    : false
        allowEmpty  : false
      },
      users : {
        description : 'map of uuid to encrypted bytes containing RsaCompressingEncryptionService'
        type        : 'object'
        required    : false
        allowEmpty  : false
      }
      sharingKey : {
        description : 'the document sharing key'
        type        : 'string'
        required    : false
        allowEmpty  : true
      }
    }
  }

  return SCHEMA
