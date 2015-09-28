define 'kryptnostic.requests', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.credential-loader'
  'kryptnostic.binary-utils'
], (require) ->
  'use strict'

  # libraries
  axios   = require 'axios'
  Promise = require 'bluebird'

  # kryptnostic
  CredentialLoader = require 'kryptnostic.credential-loader'

  # utils
  BinaryUtils = require 'kryptnostic.binary-utils'

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

  getAsUint8FromUrl = ( url ) ->
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
      new Uint8Array(response)

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

  getByteArrayAsUint8Array = (url) ->
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
        decodedData = atob(response.data)
        return BinaryUtils.stringToUint8(decodedData)
      else
        return null

  return {
    wrapCredentials,
    getAsUint8FromUrl,
    getBlockCiphertextFromUrl,
    postUint8ToUrl,
    getByteArrayAsUint8Array
  }
