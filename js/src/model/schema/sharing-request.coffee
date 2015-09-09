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
      sharingPair : {
        description : 'the encrypted object sharing pair'
        type        : 'object'
        required    : false
        allowEmpty  : true
      }
    }
  }

  return SCHEMA
