define 'soteria.hash-function', [
  'require'
  'forge.min'
], (require) ->

  forge = require 'forge.min'

  #
  # Enumeration of hash functions utilized by soteria.
  # Author: rbuckheit
  #

  return {
    SHA_256 : (data) ->
      return btoa(forge.md.sha256.create().update(atob(data)).digest().data)
  }
