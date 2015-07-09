define 'soteria.credential-provider.memory', [
  'require'
  'lodash'
  'soteria.logger'
], (require) ->

  _      = require 'lodash'
  Logger = require 'soteria.logger'

  ZERO = ''

  log = Logger.get('InMemoryCredentialProvider')

  #
  # Credential provider which stores credentials in memory.
  # Author: rbuckheit
  #
  class InMemoryCredentialProvider

    store: ({@principal, @credential, @keypair}) ->
      log.info('store')
      if !@principal or !@credential or !@keypair
        throw new Error 'must specify all credentials'

    load: ->
      log.info('load')
      if !@principal or !@credential or !@keypair
        throw new Error 'user is not authenticated'
      return {@principal, @credential, @keypair}

    destroy: ->
      @principal  = ZERO
      @credential = ZERO
      @keypair    = ZERO

  return InMemoryCredentialProvider
