define 'kryptnostic.schema.validator', [
  'require'
  'revalidator'
  'kryptnostic.logger'
], (require) ->

  logger = require('kryptnostic.logger').get('validator')

  revalidator = window

  validate = (object, classDef, schema) ->
    if not object instanceof classDef
      return

    validation = revalidator.validate(object, schema)

    if not validation.valid
      throw new Error('schema validation failed for ' + object.constructor.name)

  return { validate }
