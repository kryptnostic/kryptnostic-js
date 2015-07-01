define('soteria.cypher', ['require'], function (require) {

  // TODO: add rest of cyphers.
  return {
    AES_CTR_128: { algorithm : 'AES', mode: 'CTR', padding: 'NoPadding', keySize: 128 }
  }

});