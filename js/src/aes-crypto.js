define(['require', 'forge.min', 'src/abstract-crypto'], function(require) {
    'use strict';
    var forge = require('forge.min'),
        AbstractCryptoService = require('src/abstract-crypto');

    // TODO create constructor
    // store keys locally
    // encrypt / decrypt public methods
    // public API
    return function AesCryptoService(key) {
        this.key = key;
        this.abstractCryptoService = new AbstractCryptoService();
    };

    AesCryptoService.BLOCK_CIPHER_KEY_SIZE = 16;

    AesCryptoService.prototype = {
        constructor: AesCryptoService,

        // create a block ciphertext from plaintext
        encrypt: function(plaintext) {
            // generate random salt // empty salt
            // generate random iv
            var iv = forge.random.getBytesSync(BLOCK_CIPHER_KEY_SIZE);
            var ciphertext = abstractCryptoService.encrypt(this.key, plaintext);
            return {
                iv: btoa(this.iv),
                contents: btoa(ciphertext)
            };
        },

        // decrypt a block ciphertext into plaintext
        decrypt: function(blockCiphertext) {
            // decode base64 values
            return abstractCryptoService.decrypt(this.key, this.iv, atob(blockCiphertext.content));
        },
    };

    return AesCryptoService;
});