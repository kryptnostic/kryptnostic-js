define 'kryptnostic.security-utils', [
  'require'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  CredentialLoader = require 'kryptnostic.credential-loader'

  PRINCIPAL_HEADER  = 'X-Kryptnostic-Principal'
  CREDENTIAL_HEADER = 'X-Kryptnostic-Credential'

  wrapRequest = (request) ->
    return wrapExplicitCredentials(request, CredentialLoader.getCredentials())

  wrapExplicitCredentials = (request, { principal, credential }) ->
    request.headers[PRINCIPAL_HEADER]  = principal
    request.headers[CREDENTIAL_HEADER] = credential
    return request

  return {
    wrapRequest,
    wrapExplicitCredentials
  }
