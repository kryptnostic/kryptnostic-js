define 'kryptnostic.encrypted-search-object-key', [
  'require'
], (require) ->

  EncryptedSearchObjectKey = require 'kryptnostic.encrypted-search-object-key'

  #
  # Request object containing a pair of object ID and search bridge key.
  # Author: rbuckheit
  #
  class EncryptedSearchObjectKey

    constructor: ({ id, key }) ->
      @validate()

    validate : ->
      validators.validateId(id)
      validators.validateKey(key)
