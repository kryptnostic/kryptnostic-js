define 'kryptnostic.schema.object-tree-paged-response', [], ->

  SCHEMA = {
    properties: {
      objectMetadataTree: {
        type: 'object'
        required: true
        allowEmpty: false
      },
      isLastPage: {
        type: 'boolean'
        required: true
        allowEmpty: false
      }
    }
  }

  return SCHEMA
