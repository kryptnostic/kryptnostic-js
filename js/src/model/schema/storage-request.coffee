define 'soteria.schema.storage-request', [], ->

  SCHEMA = {
    properties: {
      type : {
        description : 'the type of object being stored'
        type        : 'string'
        required    : true
        allowEmpty  : false
      },
      objectId : {
        description : 'preset object id if overwriting another object'
        type        : 'string'
        required    : false
        allowEmpty  : false
      },
      parentObjectId : {
        description : 'id of the parent object if creating a child object'
        type        : 'string'
        required    : false
        allowEmpty  : false
      }
      body : {
        description : 'content to be encrypted'
        type        : 'string'
        required    : true
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
