define 'kryptnostic.schema.object-tree-load-request', [], ->

  SCHEMA = {
    properties: {
      objectIds : {
        type       : 'array'
        required   : true
        allowEmpty : false
      }
      loadLevels : {
        type       : 'object'
        required   : true
        allowEmpty : false
      }
      depth : {
        type       : 'number'
        required   : false
        allowEmpty : false
      }
    }
  }

  return SCHEMA
