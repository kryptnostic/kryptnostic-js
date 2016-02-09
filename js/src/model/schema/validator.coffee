define 'kryptnostic.schema.validator', [
  'require'
  'revalidator'
  'kryptnostic.logger'
], (require) ->

  logger = require('kryptnostic.logger').get('validator')

  revalidator = require('revalidator')

  validate = (object, classDef, schema) ->
    if not object instanceof classDef
      return

    validation = {}

    if revalidator && revalidator.validate
      validation = revalidator.validate(object, schema)
    else if window.validate
      validation = window.validate(object, schema)
    else
      logger.error('missing dependency: revalidator')

    if not validation.valid
      throw new Error('schema validation failed for ' + object.constructor.name)

  return { validate }
