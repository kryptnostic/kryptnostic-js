define 'kryptnostic.crypto-algorithm', [
  'require'
], (require) ->

  #
  # Enumeration of algorithms supported by kryptnostic.
  # Author: rbuckheit
  #

  return {
    RSA: 'RSA'
    AES: 'AES'
  }
