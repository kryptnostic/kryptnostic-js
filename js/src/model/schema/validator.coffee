define 'soteria.schema.validator', [
  'revalidator'
], (require) ->

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
      console.error('schema validation failed!', object.constructor.name)
      console.error(validation.errors)
      console.error('the failed object was', object)
      console.error('call trace', new Error().stack)
      throw new Error('schema validation failed', object.constructor.name)

  return {validate}