define 'soteria.schema.pending-object-request', [], (require) ->

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
        type        : 'number'
        required    : false
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
