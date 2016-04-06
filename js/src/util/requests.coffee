define 'kryptnostic.requests', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.block-ciphertext'
  'kryptnostic.credential-loader'
], (require) ->
  'use strict'

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # kryptnostic
  BlockCiphertext = require 'kryptnostic.block-ciphertext'
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
    .then (axiosResponse) ->
      if (axiosResponse and
          axiosResponse.data and
          axiosResponse.data.byteLength and
          axiosResponse.data.byteLength > 0)
        return new Uint8Array(axiosResponse.data)
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
    .then (axiosResponse) ->
      if axiosResponse and axiosResponse.data
        try
          return new BlockCiphertext(axiosResponse.data)
        catch e
          return null
      else
        return null

  # data must be a Uint8Array
  xhrPost = (data, url) ->
    Promise.resolve()
    .then ->
      credentials = new CredentialLoader().getCredentials()
      xhr = new XMLHttpRequest()
      xhr.open('POST', url, false) # false means synchronous
      xhr.setRequestHeader(PRINCIPAL_HEADER, credentials.principal)
      xhr.setRequestHeader(CREDENTIAL_HEADER, credentials.credential)
      xhr.setRequestHeader('Content-Type', 'application/octet-stream')
      xhr.send(data)

  return {
    PRINCIPAL_HEADER,
    CREDENTIAL_HEADER,
    wrapCredentials,
    getAsUint8FromUrl,
    getBlockCiphertextFromUrl,
    xhrPost
  }
