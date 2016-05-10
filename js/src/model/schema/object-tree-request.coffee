define 'kryptnostic.schema.object-tree-request', [], ->

  SCHEMA = {
    properties: {
      rootObjectKey: {
        type: 'object'
        required: true
        allowEmpty: false
      },
      typeLoadLevels: {
        type: 'object'
        required: true
        allowEmpty: false
      },
      loadDepth: {
        type: 'number'
        required: true
        allowEmpty: false
      }
    }
  }

  return SCHEMA
