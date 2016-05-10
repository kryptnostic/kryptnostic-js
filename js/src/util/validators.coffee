# coffeelint: disable=cyclomatic_complexity

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
    regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-4][0-9a-f]{3}-[0-9a-f]{4}-[0-9a-f]{12}$/
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

    isValid = true
    _.forEach(uuids, (uuid) ->
      if not validateUuid(uuid)
        isValid = false
    )

    return isValid

  validateVersionedObjectKey = (versionedObjectKey) ->

    if not _.isObject(versionedObjectKey)
      return false

    if not validateUuid(versionedObjectKey.objectId)
      return false

    if not _.isFinite(versionedObjectKey.objectVersion)
      return false

    return true

  validateVersionedObjectKeys = (versionedObjectKeys) ->

    if not _.isArray(versionedObjectKeys)
      return false

    isValid = true
    _.forEach(versionedObjectKeys, (versionedObjectKey) ->
      if not validateVersionedObjectKey(versionedObjectKey)
        isValid = false
    )

    return isValid

  validateBlockCipherText = (blockCipherText) ->

    if not _.isObject(blockCipherText)
      return false

    if _.isEmpty(blockCipherText.contents) or not _.isString(blockCipherText.contents)
      return false

    if _.isEmpty(blockCipherText.iv) or not _.isString(blockCipherText.iv)
      return false

    if not _.isEmpty(blockCipherText.salt) and not _.isString(blockCipherText.salt)
      return false

    if not _.isEmpty(blockCipherText.tag) and not _.isString(blockCipherText.tag)
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
    validateVersionedObjectKeys
    validateBlockCipherText
  }
