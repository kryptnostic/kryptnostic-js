define 'soteria.schema.pending-object-request', [], ->

  SCHEMA = {
    properties : {
      type : {
        description : 'the type of object being stored'
        type        : 'string'
        required    : true
        allowEmpty  : false
      },
      parentObjectId : {
        description : 'id of the parent object if creating a child object'
        type        : 'string'
        required    : false
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
