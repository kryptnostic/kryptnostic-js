define 'kryptnostic.schema.object-tree-paged-request', [], ->

  SCHEMA = {
    properties: {
      objectKey: {
        type: 'object'
        required: true
        allowEmpty: false
      },
      latestObjectId: {
        type: 'string'
        required: false
        allowEmpty: false
        pattern: '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$'
      },
      latestObjectVersion: {
        type: 'number'
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
        required: false
        allowEmpty: false
      },
      pageSize: {
        type: 'number'
        required: false
        allowEmpty: false
      },
      objectIdsToFilter: {
        type: 'object'
        require: false
        allowEmpty: false
      }
    }
  }

  return SCHEMA
