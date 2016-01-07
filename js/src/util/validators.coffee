define 'kryptnostic.validators', [
  'require'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  _      = require 'lodash'
  Logger = require 'kryptnostic.logger'

  log = Logger.get('validators')

  validateNonEmptyString = (value, desc = 'value') ->
    if not _.isString(value)
      log.error("#{desc} is not a string", value)
      throw new Error "#{desc} is not a string"
    if _.isEmpty(value)
      log.error("#{desc} is empty", value)
      throw new Error "#{desc} is empty"

  validateUuid = (uuid) ->
    regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$/;
    return regex.test(uuid)

  validateId = (id) ->
    validateNonEmptyString(id, 'id')

  validateKey = (key) ->
    validateNonEmptyString(key, 'key')

  validateObjectType = (type) ->
    validateNonEmptyString(type, 'object type')

  validateUuids = (uuids) ->

    if not _.isArray(uuids)
      return false

    _.forEach(uuids, (uuid) ->
      if not validateUuid(uuid)
        return false
    )

    return true

  validateVersionedObjectKey = (versionedObjectKey) ->

    if not _.isObject(versionedObjectKey)
      return false

    if not validateUuid(versionedObjectKey.objectId)
      return false

    if not _.isFinite(versionedObjectKey.objectVersion)
      return false

    return true

  validateObjectCryptoService = (objectCryptoService) ->

    if not _.isString(objectCryptoService) or _.isEmpty(objectCryptoService)
      return false

    return true

  return {
    validateId
    validateKey
    validateUuid
    validateUuids
    validateObjectType
    validateNonEmptyString
    validateVersionedObjectKey
    validateObjectCryptoService
  }
