define 'soteria.credential-provider.session', [
  'require'
], (require) ->

  PRINCIPAL_KEY  = 'soteria.principal'
  CREDENTIAL_KEY = 'soteria.credential'

  ZERO = ''

  #
  # Credential provider which stores credentials in HTML5 session storage.
  # Author: rbuckheit
  #
  class SessionStorageCredentialProvider

    constructor: ->
      unless window.sessionStorage?
        throw new Error 'session storage is not supported'

    store: ({principal, credential, password}) ->
      if !principal or !credential or !password
        throw new Error 'must specify username and password'
      sessionStorage.setItem(PRINCIPAL_KEY, principal)
      sessionStorage.setItem(CREDENTIAL_KEY, credential)

    load: ->
      principal  = sessionStorage.getItem(PRINCIPAL_KEY)
      credential = sessionStorage.getItem(CREDENTIAL_KEY)
      return { principal, credential }

    destroy: ->
      sessionStorage.setItem(PRINCIPAL_KEY, ZERO)
      sessionStorage.setItem(CREDENTIAL_KEY, ZERO)

  return SessionStorageCredentialProvider
