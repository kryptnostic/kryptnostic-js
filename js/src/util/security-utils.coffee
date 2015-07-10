define 'soteria.security-utils', [
  'require'
  'soteria.credential-store'
], (require) ->
  'use strict'

  CredentialStore = require 'soteria.credential-store'

  PRINCIPAL_COOKIE  = 'X-Kryptnostic-Principal'
  CREDENTIAL_COOKIE = 'X-Kryptnostic-Credential'

  wrapRequest = (request) ->
    request.beforeSend = (xhr) ->
      if CredentialStore.isInitialized()
        {principal, credential} = CredentialStore.credentialProvider.load()
        xhr.setRequestHeader(PRINCIPAL_COOKIE, principal)
        xhr.setRequestHeader(CREDENTIAL_COOKIE, credential)
      else
        throw new Error 'user is not authenticated'

    return request

  return {
    wrapRequest
  }
