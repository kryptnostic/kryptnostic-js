define 'soteria.schema.sharing-request', [], (require) ->

  SCHEMA = {
    properties: {
      id : {
        description : 'id of the object being shared'
        type        : 'number'
        required    : false
        allowEmpty  : false
      },
      users : {
        description : 'map of userKey to encrypted bytes containing rsa compressing encryption service'
        type        : 'object'
        required    : false
        allowEmpty  : false
      }
      sharingKey : {
        description : 'the document sharing key'
        type        : 'string'
        required    : true
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
