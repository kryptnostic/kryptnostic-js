define 'kryptnostic.cypher', [], (require) ->

  return {
    AES_CTR_128: { algorithm : 'AES', mode: 'CTR', padding: 'NoPadding', keySize: 128 }
    AES_GCM_256: { algorithm : 'AES', mode: 'GCM', padding: 'NoPadding', keySize: 256 }
  }
