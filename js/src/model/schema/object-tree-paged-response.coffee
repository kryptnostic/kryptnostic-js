define 'kryptnostic.schema.object-tree-paged-response', [], ->

  SCHEMA = {
    properties: {
      objectMetadataTree: {
        type: 'object'
        required: true
        allowEmpty: false
      },
      nextPageUrlPath: {
        type: ['string', 'null']
        required: true
        allowEmpty: true
      }
    }
  }

  return SCHEMA
