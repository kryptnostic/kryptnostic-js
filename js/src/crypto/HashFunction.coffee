define 'kryptnostic.hash-function', [
  'require'
  'forge'
  'murmurhash3'
], (require) ->

  forge       = require 'forge'
  murmurhash3 = require 'murmurhash3'

  SHA_256 = (data) ->
    return forge.md.sha256.create().update(data).digest().getBytes()

  SHA_256_TO_128 = (data) ->
    sha256HashBuffer = forge.md.sha256.create().update(data).digest()
    halfTheBytes = sha256HashBuffer.length() / 2
    leftHalfBuffer = new forge.util.ByteBuffer(sha256HashBuffer.getBytes(halfTheBytes))
    rightHalfBuffer = new forge.util.ByteBuffer(sha256HashBuffer.getBytes())
    return forge.util.xorBytes(leftHalfBuffer.getBytes(), rightHalfBuffer.getBytes(), halfTheBytes)

  # murmur3 128 bit with seed of 0.
  MURMUR3_128 = (string) ->
    return murmurhash3.x86.hash128(string)

  return {
    SHA_256,
    SHA_256_TO_128,
    MURMUR3_128
  }
