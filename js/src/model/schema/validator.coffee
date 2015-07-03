define 'soteria.schema.validator', [
  'require'
  'revalidator'
  'soteria.logger'
], (require) ->

  logger = require('soteria.logger').get('validator')

  revalidator = window

  #
  # Validates request objects against their schemas.
  # Author: rbuckheit
  #

  validate = (object, classDef, schema) ->
    if not object instanceof classDef
      return

    validation = revalidator.validate(object, schema)

    if not validation.valid
      logger.error('schema validation failure', {
        className : object.constructor.name
        errors    : validation.errors
        object    : object
        callTrace : new Error().stack
      })
      throw new Error('schema validation failed for ' + object.constructor.name)

  return {validate}
