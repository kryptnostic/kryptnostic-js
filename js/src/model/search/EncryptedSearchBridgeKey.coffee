define 'kryptnostic.encrypted-search-bridge-key', [
  'require'
  'kryptnostic.validators'
], (require) ->

  validators = require 'kryptnostic.validators'

  #
  # Request model or an encrypted search bridge key.
  # Author: rbuckheit
  #

  class EncryptedSearchBridgeKey

    @create : (bridge) ->
      # needs to be fixed
      rows   = [ bridge ]
      # com.kryptnostic.linear.EnhancedBitMatrix
      bridge = { rows, '@class' : 'EnhancedBitMatrix' }
      return new EncryptedSearchBridgeKey({ bridge })

    constructor: ({ @bridge }) ->

    validate: ->
      validators.validateNonEmptyString(@bridge['@class'])

