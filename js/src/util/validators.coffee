define 'kryptnostic.validators', [
  'require'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  _      = require 'lodash'
  Logger = require 'kryptnostic.logger'

  log = Logger.get('validators')

  #
  # Utility class containing shared validation functions for models.
  # Author: rbuckheit
  #

  validateNonEmptyString = (value, desc = 'value') ->
    if not _.isString(value)
      log.error("#{desc} is not a string", value)
      throw new Error "#{desc} is not a string"
    if _.isEmpty(value)
      log.error("#{desc} is empty", value)
      throw new Error "#{desc} is empty"

  validateUuid = (uuid) ->
    validateNonEmptyString(uuid, 'uuid')

  validateId = (id) ->
    validateNonEmptyString(id, 'id')

  validateKey = (key) ->
    validateNonEmptyString(key, 'key')

  validateObjectType = (type) ->
    validateNonEmptyString(type, 'object type')

  validateUuids = (uuids) ->
    unless _.isArray(uuids)
      log.error('uuid list is not an array', { uuids })
      throw new Error 'uuid list is not an array'

    uuids.forEach (uuid) ->
      validateUuid(uuid)

  return {
    validateId
    validateKey
    validateUuid
    validateUuids
    validateObjectType
    validateNonEmptyString
  }
