define 'kryptnostic.search.random-index-generator', [
  'require'
], (require) ->

  #
  # Generates pseudorandom unsigned 32-bit integers for padding token locations.
  # Author: rbuckheit
  #
  class RandomIndexGenerator

    generate: (count) ->
      buffer = new Uint32Array(count)
      window.crypto.getRandomValues(buffer)
      return Array.prototype.slice.call(buffer)

  return RandomIndexGenerator
