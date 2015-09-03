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

  # sha 256
  SHA_256 = (data) ->
    return btoa(forge.md.sha256.create().update(atob(data)).digest().data)

  # murmur3 128 bit with seed of 0.
  MURMUR3_128 = (string) ->
    return murmurhash3.x86.hash128(string)

  return {
    SHA_256,
    MURMUR3_128
  }
