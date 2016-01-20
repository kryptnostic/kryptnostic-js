define 'kryptnostic.schema.storage-request', [], ->

  SCHEMA = {
    properties: {
      parentId: {
        description : 'object ID of the parent object if creating a child object'
        type        : 'string'
        required    : false
        allowEmpty  : false
        pattern     : '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$'
      }
      typeId: {
        description : 'the type ID of object being stored'
        type        : 'string'
        required    : false
        allowEmpty  : false
        pattern     : '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$'
      },
      typeName: {
        description : 'the type name of object being stored'
        type        : 'string'
        required    : true
        allowEmpty  : false
      },
      body: {
        description : 'content to be encrypted'
        type        : 'string'
        required    : true
        allowEmpty  : false
      }
      isSearchable: {
        description : 'indicates whether the object should be indexed'
        type        : 'boolean'
        required    : false
      }
    }
  }

  return SCHEMA
