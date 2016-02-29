define 'kryptnostic.cypher', [], (require) ->

  #
  # Enumeration of cyphers.
  # Author: rbuckheit
  #
  return {
    AES_CTR_128: { algorithm : 'AES', mode: 'CTR', padding: 'NoPadding', keySize: 128 }
    AES_GCM_128: { algorithm : 'AES', mode: 'GCM', padding: 'NoPadding', keySize: 128 }
  }
