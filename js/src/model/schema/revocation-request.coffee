define 'kryptnostic.schema.revocation-request', [], ->

  return {
    properties: {
      id : {
        description : 'id of the object being shared'
        type        : 'string'
        required    : true
        allowEmpty  : false
      },
      usersKeys : {
        description : 'list of user keys whose access must be revoked'
        type        : 'array'
        required    : true
        allowEmpty  : false
      }
    }
  }

