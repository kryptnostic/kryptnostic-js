define 'kryptnostic.schema.revocation-request', [], ->

  return {
    properties: {
      id : {
        description : 'VersionedObjectKey of the object being revoked'
        type        : 'object'
        required    : true
        allowEmpty  : false
      },
      users : {
        description : 'list of user keys whose access must be revoked'
        type        : 'array'
        required    : true
        allowEmpty  : false
      }
    }
  }
