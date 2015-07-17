define 'soteria.credential-provider.local-storage', [
  'require'
  'soteria.logger'
  'soteria.keypair-serializer'
], (require) ->

  Logger          = require 'soteria.logger'
  KeypairSerializer = require 'soteria.keypair-serializer'

  log = Logger.get('LocalStorageCredentialProvider')

  PRINCIPAL_KEY  = 'soteria.principal'
  CREDENTIAL_KEY = 'soteria.credential'
  KEYPAIR_KEY    = 'soteria.keypair'

  #
  # Credential provider which stores credentials in memory.
  # Author: rbuckheit
  #
  class LocalStorageCredentialProvider

    @store: ({principal, credential, keypair}) ->
      unless !!principal and !!credential
        throw new Error 'must specify all credentials'

      log.info('store')
      window.localStorage.setItem(PRINCIPAL_KEY, principal)
      window.localStorage.setItem(CREDENTIAL_KEY, credential)

      if !!keypair
        keypair = KeypairSerializer.serialize(keypair)
        window.localStorage.setItem(KEYPAIR_KEY, keypair)

    @load: ->
      principal  = window.localStorage.getItem(PRINCIPAL_KEY)
      credential = window.localStorage.getItem(CREDENTIAL_KEY)
      keypair    = window.localStorage.getItem(KEYPAIR_KEY)

      keypair = KeypairSerializer.hydrate(keypair)

      unless !!principal and !!credential
        throw new Error 'user is not authenticated'

      return { principal, credential, keypair }

    @destroy: ->
      window.localStorage.setItem(PRINCIPAL_KEY, undefined)
      window.localStorage.setItem(CREDENTIAL_KEY, undefined)
      window.localStorage.setItem(KEYPAIR_KEY, undefined)
      log.info('destroyed credentials')

  return LocalStorageCredentialProvider
