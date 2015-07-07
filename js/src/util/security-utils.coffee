define 'soteria.security-utils', [], ->
  'use strict'

  PRINCIPAL_COOKIE  = 'X-Kryptnostic-Principal'
  CREDENTIAL_COOKIE = 'X-Kryptnostic-Credential'

  wrapRequest = (request) ->
    request.beforeSend = (xhr) ->
      # TODO: better cred storage strategy
      principal  = sessionStorage.getItem('soteria.principal')
      credential = sessionStorage.getItem('soteria.credential')

      xhr.setRequestHeader(PRINCIPAL_COOKIE, principal)
      xhr.setRequestHeader(CREDENTIAL_COOKIE, credential)

    return request

  return {
    wrapRequest
  }
