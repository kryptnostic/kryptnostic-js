define 'kryptnostic.requests', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # kryptnostic
  CredentialLoader = require 'kryptnostic.credential-loader'

  # constants
  PRINCIPAL_HEADER  = 'X-Kryptnostic-Principal'
  CREDENTIAL_HEADER = 'X-Kryptnostic-Credential'

  #
  # utility methods for axios request objects
  #

  # DOTO - KJS-22
  wrapCredentials = (request, credentials = {}) ->
    if _.isEmpty(credentials)
      credentials = new CredentialLoader().getCredentials()

    _.defaults(request, { headers: {} })
    request.headers[PRINCIPAL_HEADER]  = credentials.principal
    request.headers[CREDENTIAL_HEADER] = credentials.credential
    return request

  getAsUint8FromUrl = (url) ->
    Promise.resolve(
      axios(
        wrapCredentials({
          url          : url
          method       : 'GET'
          responseType : 'arraybuffer'
        })
      )
    )
    .then (response) ->
      if (response? and
          response.data? and
          response.data.byteLength? and
          response.data.byteLength > 0)
        return new Uint8Array(response.data)
      else
        return null

  getBlockCiphertextFromUrl = (url) ->
    Promise.resolve(
      axios(
        wrapCredentials({
          url          : url
          method       : 'GET'
          responseType : 'json'
        })
      )
    )
    .then (response) ->
      if response? and response.data?
        try
          return new BlockCiphertext(response.data)
        catch e
          return null
      else
        return null

  postUint8ToUrl = (url, data) ->
    Promise.resolve(
      axios(
        wrapCredentials({
          url    : url
          method : 'POST'
          data   : data
        })
      )
    )

  return {
    wrapCredentials,
    getAsUint8FromUrl,
    getBlockCiphertextFromUrl,
    postUint8ToUrl
  }
