define 'soteria.credential-provider.memory', [
  'require'
  'soteria.logger'
], (require) ->

  Logger = require 'soteria.logger'

  log = Logger.get('InMemoryCredentialProvider')

  #
  # Credential provider which stores credentials in memory.
  # Author: rbuckheit
  #
  class InMemoryCredentialProvider

    @store: ({@principal, @credential, @keypair}) ->
      unless !!@principal and !!@credential
        throw new Error 'must specify all credentials'
      log.info('stored credentials')

    @load: ->
      unless !!@principal and !!@credential
        throw new Error 'user is not authenticated'
      return { @principal, @credential, @keypair }

    @destroy: ->
      @principal  = undefined
      @credential = undefined
      @keypair    = undefined
      log.info('destroyed credentials')

  return InMemoryCredentialProvider
