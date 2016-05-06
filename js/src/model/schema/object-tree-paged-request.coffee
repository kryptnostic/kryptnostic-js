define 'kryptnostic.schema.object-tree-paged-request', [], ->

  SCHEMA = {
    properties: {
      rootObjectKey: {
        type: 'object'
        required: true
        allowEmpty: false
      },
      lastChildObjectKey: {
        type: 'object'
        required: false
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
      },
      pageSize: {
        type: 'number'
        required: true
        allowEmpty: false
      },
      pagingDirection: {
        type: 'string'
        required: false
        allowEmpty: false
      }
    }
  }

  return SCHEMA
