define 'kryptnostic.encrypted-search-object-key', [
  'require'
  'kryptnostic.validators'
], (require) ->

  validators = require 'kryptnostic.validators'

  { validateId, validateKey } = validators

  #
  # Request object containing a pair of object ID and search bridge key.
  # Author: rbuckheit
  #
  class EncryptedSearchObjectKey

    constructor: ({ @id, @key }) ->
      @validate()

    validate : ->
      validateId(@id)
      unless @key.constructor.name is 'EncryptedSearchBridgeKey'
        throw new Error 'key must be a bridge key'
      @key.validate()
