define 'soteria.schema.kryptnostic-object', [
  'require'
  'soteria.schema.object-metadata'
], (require) ->

  OBJECT_METADATA_SCHEMA = require 'soteria.schema.object-metadata'

  SCHEMA = {
    properties: {
      metadata : OBJECT_METADATA_SCHEMA
    }
  }
