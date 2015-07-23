define 'kryptnostic.schema.kryptnostic-object', [
  'require'
  'kryptnostic.schema.object-metadata'
], (require) ->

  OBJECT_METADATA_SCHEMA = require 'kryptnostic.schema.object-metadata'

  SCHEMA = {
    properties: {
      metadata : OBJECT_METADATA_SCHEMA
    }
  }
