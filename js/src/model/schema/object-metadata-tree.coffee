define 'kryptnostic.schema.object-metadata-tree', [], ->

  SCHEMA = {
    type: 'object',
    description: 'Map<java.util.UUID, com.kryptnostic.v2.storage.models.ObjectMetadataEncryptedNode>',
    patternProperties: {
      '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$': {
        children: {
          type: 'object'
        },
        contents: {
          type: 'object',
          properties: {
            iv              : { type: 'string', required: true, allowEmpty: false },
            salt            : { type: 'string', required: true, allowEmpty: false },
            contents        : { type: 'string', required: true, allowEmpty: false },
            tag             : { type: 'string', required: false, allowEmpty: false },
            encryptedLength : { type: 'string', required: false, allowEmpty: false }
          }
        },
        metadata: {
          type: 'object'
          description: 'com.kryptnostic.v2.storage.models.ObjectMetadata'
          properties: {
            id: {
              type: 'string',
              pattern: '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$',
              required: true,
              allowEmpty: false
            },
            type: {
              type: 'string',
              pattern: '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$',
              required: true,
              allowEmpty: false
            },
            version: {
              type: 'number',
              required: true,
              allowEmpty: false
            },
            size: {
              type: 'number',
              required: true,
              allowEmpty: false
            },
            creator: {
              type: 'string',
              pattern: '^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$'
              },
            requiredCryptoMats: {
              type: 'array',
              required: true,
              allowEmpty: false
            },
            timeCreated: {
              type: 'number',
              required: true,
              allowEmpty: false
            }
          }
        }
      }
    }
  }

  return SCHEMA
