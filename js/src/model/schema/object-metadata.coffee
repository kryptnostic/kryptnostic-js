define 'soteria.schema.object-metadata', [], (require) ->

  # TODO finish schema

  SCHEMA = {
    properties: {
      id               : { type: 'string' }
      type             : { type: 'string' }
      timeCreated      : { type: 'number' }
      version          : { type: 'number' }
      total            : { type: 'number' }
      childObjectCount : { type: 'number' }
      owners           : { type: 'array' }
      readers          : { type: 'array' }
      writers          : { type: 'array' }
      name             : {
        type        : 'object'
        description : 'encrypted class name'
        properties : {
          iv       : {type: 'string'}
          salt     : {type:'string'}
          contents : {type: 'string'}
        }
      }
      strategy : {
        type       : 'object'
        required   : true
        properties : {
          '@class': {
            type       : 'string'
            required   : true
            allowEmpty : false
          }
        }
      }
    }
  }

  return SCHEMA