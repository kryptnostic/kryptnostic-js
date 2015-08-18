define 'kryptnostic.salt-generator', [
  'require'
  'forge'
], (require) ->

  Forge = require 'forge'

  generateSalt = (byteCount) ->
    return Forge.random.getBytesSync(byteCount)

  return { generateSalt }
