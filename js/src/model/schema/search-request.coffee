define 'kryptnostic.schema.search-request', [], ->

  SCHEMA = {
    properties: {
      query : {
        description : 'array of FHE-encrypted search tokens represented as an Uint8Array'
        type        : 'array'
        required    : true
        allowEmpty  : false
      }
      offset: {
        type        : 'number'
        required    : false
        allowEmpty  : false
      }
      max: {
        type        : 'number'
        required    : false
        allowEmpty  : false
      }
    }
  }

  return SCHEMA
