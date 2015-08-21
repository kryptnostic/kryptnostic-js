define 'kryptnostic.hash-function', [
  'require'
  'forge'
  'murmurhash3'
], (require) ->

  forge       = require 'forge'
  murmurhash3 = require 'murmurhash3'

  #
  # Enumeration of hash functions utilized by kryptnostic.
  # Author: rbuckheit
  #

  SHA_256 = (data) ->
    return btoa(forge.md.sha256.create().update(atob(data)).digest().data)

  MURMUR3_128 = (string) ->
    return murmurhash3.x86.hash128(string)

  return {
    SHA_256,
    MURMUR3_128
  }
