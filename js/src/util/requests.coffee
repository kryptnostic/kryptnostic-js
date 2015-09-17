define 'kryptnostic.requests', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  axios            = require 'axios'
  CredentialLoader = require 'kryptnostic.credential-loader'
  Promise          = require 'bluebird'

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

  getAsUint8FromUrl = ( url ) ->
    Promise.resolve(
      axios(
        wrapCredentials({
          url          : url
          method       : 'GET'
          responseType : 'arraybuffer'
        })))
    .then (response) ->
      new Uint8Array(response)

  getBlockCiphertextFromUrl = (url) ->
    Promise.resolve(
      axios(
        wrapCredentials({
          url          : url
          method       : 'GET'
          responseType : 'json'
        })))
    .then (response) ->
      if response isnt null and typeof response isnt 'undefined'
        return response
      else
        return null

  postUint8ToUrl = (url, data) ->
    Promise.resolve(
      axios(
        wrapCredentials({
          url    : url
          method : 'POST'
          data   : data
        })))

  return {
    wrapCredentials,
    getAsUint8FromUrl,
    getBlockCiphertextFromUrl,
    postUint8ToUrl,
  }
