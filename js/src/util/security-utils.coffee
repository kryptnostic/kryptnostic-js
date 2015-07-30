define 'kryptnostic.security-utils', [
  'require'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  CredentialLoader = require 'kryptnostic.credential-loader'

  PRINCIPAL_HEADER  = 'X-Kryptnostic-Principal'
  CREDENTIAL_HEADER = 'X-Kryptnostic-Credential'

  wrapRequest = (request) ->
    { principal, credential } = CredentialLoader.getCredentials()
    request.headers = _.extend({}, request.headers)
    request.headers[PRINCIPAL_HEADER]  = principal
    request.headers[CREDENTIAL_HEADER] = credential
    return request

  return {
    wrapRequest
  }
