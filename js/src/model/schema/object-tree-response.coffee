define 'kryptnostic.schema.object-tree-response', [], ->

  SCHEMA = {
    properties: {
      objectMetadataTree: {
        type: 'object'
        required: true
        allowEmpty: false
      }
    }
  }

  return SCHEMA
