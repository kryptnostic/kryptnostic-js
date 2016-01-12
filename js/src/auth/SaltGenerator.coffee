define 'kryptnostic.salt-generator', [
  'require'
  'forge'
], (require) ->

  Forge = require 'forge'

  # WebCrypto API
  webCryptoApi = null
  if window.crypto?.subtle? or window.msCrypto?.subtle?
    webCryptoApi = window.crypto or window.msCrypto

  generateSalt = (byteCount) ->
    if webCryptoApi
      return webCryptoApi.getRandomValues(new Uint8Array(byteCount))
    else
      return Forge.random.getBytesSync(byteCount)

  return { generateSalt }
