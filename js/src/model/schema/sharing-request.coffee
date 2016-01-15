define 'kryptnostic.schema.sharing-request', [], ->

  SCHEMA = {
    properties: {
      id : {
        description : 'VersionedObjectKey of the object being shared'
        type        : 'object'
        required    : true
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
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
