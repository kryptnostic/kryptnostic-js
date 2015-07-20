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

  isUndefined = (serialized) ->
    return serialized is SERIALIZED_UNDEFINED_VALUE

  #
  # Credential provider which is compatible with key/value storage
  # interfaces implementing setItem and getItem.
  #
  # Author: rbuckheit
  #
  class KeyValueCredentialProvider

    @store: (@storage, {principal, credential, keypair}) ->
      unless !!principal and !!credential
        throw new Error 'must specify all credentials'

      log.info('store')
      @storage.setItem(PRINCIPAL_KEY, principal)
      @storage.setItem(CREDENTIAL_KEY, credential)

      if !!keypair
        keypair = KeypairSerializer.serialize(keypair)
        @storage.setItem(KEYPAIR_KEY, keypair)

    @load: (@storage) ->
      principal  = @storage.getItem(PRINCIPAL_KEY)
      credential = @storage.getItem(CREDENTIAL_KEY)
      keypair    = @storage.getItem(KEYPAIR_KEY)

      log.info('load', {principal, credential, keypair})

      keypair    = KeypairSerializer.hydrate(keypair)

      hasPrincipal  = !!principal and not isUndefined(principal)
      hasCredential = !!credential and not isUndefined(credential)

      unless hasPrincipal and hasCredential
        throw new Error 'user is not authenticated'

      return { principal, credential, keypair }

    @destroy: (@storage) ->
      @storage.setItem(PRINCIPAL_KEY, undefined)
      @storage.setItem(CREDENTIAL_KEY, undefined)
      @storage.setItem(KEYPAIR_KEY, undefined)
      log.info('destroyed credentials')

  return KeyValueCredentialProvider
