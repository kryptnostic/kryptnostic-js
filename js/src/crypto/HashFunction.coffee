define 'soteria.hash-function', [
  'require'
  'forge'
], (require) ->

  forge = require 'forge'

  #
  # Enumeration of hash functions utilized by soteria.
  # Author: rbuckheit
  #

  return {
    SHA_256 : (data) ->
      return btoa(forge.md.sha256.create().update(atob(data)).digest().data)
  }
