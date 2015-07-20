define 'soteria.credential-provider.key-value', [
  'require'
  'soteria.logger'
  'soteria.keypair-serializer'
], (require) ->

  Logger            = require 'soteria.logger'
  KeypairSerializer = require 'soteria.keypair-serializer'

  log = Logger.get('KeyValueCredentialProvider')

  PRINCIPAL_KEY  = 'soteria.principal'
  CREDENTIAL_KEY = 'soteria.credential'
  KEYPAIR_KEY    = 'soteria.keypair'

  SERIALIZED_UNDEFINED_VALUE = 'undefined'

  isDefined = (serialized) ->
    return !!serialized and serialized isnt SERIALIZED_UNDEFINED_VALUE

  #
  # Credential provider which is compatible with key/value storage
  # interfaces implementing setItem and getItem.
  #
  # Author: rbuckheit
  #
  class KeyValueCredentialProvider

    @store: (@storage, {principal, credential, keypair}) ->
      log.info('store')

      unless isDefined(principal) and isDefined(credential)
        throw new Error 'must specify all credentials'

      @storage.setItem(PRINCIPAL_KEY, principal)
      @storage.setItem(CREDENTIAL_KEY, credential)

      if !!keypair
        keypair = KeypairSerializer.serialize(keypair)
        @storage.setItem(KEYPAIR_KEY, keypair)

    @load: (@storage) ->
      principal  = @storage.getItem(PRINCIPAL_KEY)
      credential = @storage.getItem(CREDENTIAL_KEY)
      keypair    = @storage.getItem(KEYPAIR_KEY)
      keypair    = KeypairSerializer.hydrate(keypair)

      unless isDefined(principal) and isDefined(credential)
        throw new Error 'user is not authenticated'

      return { principal, credential, keypair }

    @destroy: (@storage) ->
      log.info('destroy')
      @storage.setItem(PRINCIPAL_KEY, undefined)
      @storage.setItem(CREDENTIAL_KEY, undefined)
      @storage.setItem(KEYPAIR_KEY, undefined)

  return KeyValueCredentialProvider
