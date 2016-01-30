define 'kryptnostic.schema.inverted-index-segment', [], ->

  SCHEMA = {
    properties: {
      key: {
        description : 'VersionedObjectKey of the object',
        type        : 'object',
        required    : true,
        allowEmpty  : false
      },
      token: {
        description : 'the token being indexed for search',
        type        : 'string',
        required    : true,
        allowEmpty  : false
      },
      indices: {
        description : 'the 2D array of indices (locations)',
        type        : 'array',
        required    : true,
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
