define 'kryptnostic.cypher', [], (require) ->

  #
  # Enumeration of cyphers.
  # Author: rbuckheit
  #
  return {
    AES_CTR_128: {
      algorithm : 'AES-CTR',
      cipher: 'AES',
      mode: 'CTR',
      keySize: 128,
      padding: 'NoPadding'
    }
  }
