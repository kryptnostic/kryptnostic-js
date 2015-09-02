define 'kryptnostic.requests', [
  'require'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  CredentialLoader = require 'kryptnostic.credential-loader'

  PRINCIPAL_HEADER  = 'X-Kryptnostic-Principal'
  CREDENTIAL_HEADER = 'X-Kryptnostic-Credential'

  #
  # Utility methods for axios request objects.
  # Author: rbuckheit
  #

  wrapCredentials = (request, credentials = {}) ->
    if _.isEmpty(credentials)
      credentials = new CredentialLoader().getCredentials()

    _.defaults(request, { headers: {} })
    request.headers[PRINCIPAL_HEADER]  = credentials.principal
    request.headers[CREDENTIAL_HEADER] = credentials.credential
    return request

  getAsBlobFromUrl: (url) ->
    return Promise.resolve()
    .then ->
      Promise.resolve(
        axios(
          wrapCredentials({
            url          : url
            method       : 'GET'
            responseType : 'blob'
          })))

  postToUrl: (url, data) ->
    return Promise.resolve()
    .then ->
      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            url    : url
            method : 'POST'
            data   : data
          })))

  return {
    wrapCredentials,
    getAsBlobFromUrl,
    postToUrl,
  }
