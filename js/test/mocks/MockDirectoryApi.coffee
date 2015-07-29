define 'kryptnostic.mock.directory-api', [
  'require'
  'bluebird'
  'kryptnostic.block-ciphertext'
], (require) ->

  BlockCiphertext = require 'kryptnostic.block-ciphertext'
  Promise         = require 'bluebird'

  SALT_BLOCK_CIPHERTEXT = {
    iv       :'4Iho8AfsMmeA7fmDibn+TQ=='
    salt     :'BZ2ZMwycMa0Z06gt8tr3uKtdqX8='
    contents :'CTpzjW3mxT/lV+eHDV+ijkWS5t6Jsm970n0w+dc6wv4='
  }

  RSA_KEY_BLOCK_CIPERTEXT = {
    iv       : 'L6r4+c78Gfry/i9hJB8xHg==',
    salt     : 'u6fNe//Ktx9HJvfVKB38wLXfgJI=',
    contents : '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'
  }


  class MockDirectoryApi

    getSalt: ({username, realm}) ->
      return Promise.resolve(new BlockCiphertext(SALT_BLOCK_CIPHERTEXT))

    getPrivateKey: ->
      return Promise.resolve(new BlockCiphertext(RSA_KEY_BLOCK_CIPERTEXT))

  return MockDirectoryApi
