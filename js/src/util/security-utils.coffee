define 'soteria.security-utils', [
  'require'
  'soteria.credential-loader'
], (require) ->
  'use strict'

  CredentialLoader = require 'soteria.credential-loader'

  PRINCIPAL_COOKIE  = 'X-Kryptnostic-Principal'
  CREDENTIAL_COOKIE = 'X-Kryptnostic-Credential'

  wrapRequest = (request) ->
    request.beforeSend = (xhr) ->
      { principal, credential } = CredentialLoader.getCredentials()
      xhr.setRequestHeader(PRINCIPAL_COOKIE, principal)
      xhr.setRequestHeader(CREDENTIAL_COOKIE, credential)

    return request

  return {
    wrapRequest
  }
