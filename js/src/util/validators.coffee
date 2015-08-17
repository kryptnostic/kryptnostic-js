define 'kryptnostic.validators', [
  'require'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'

  log = Logger.get('validators')

  #
  # Utility class containing shared validation functions for models.
  # Author: rbuckheit
  #

  validateNonEmptyString = (id) ->
    if not _.isString(id)
      log.error('non-string id', { id })
      throw new Error 'id is not a string'
    if _.isEmtpy(id)
      log.error('empty id', { id })
      throw new Error 'id is empty'

  validateUuid = (uuid) ->
    validateNonEmptyString(uuid)

  validateId = (id) ->
    validateNonEmptyString(id)

  validateKey = (key) ->
    validateNonEmptyString(key)

  validateObjectType = (type) ->
    validateNonEmptyString(type)

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
