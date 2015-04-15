define(['require', 'forge.min', 'src/abstract-crypto'], function(require) {
    'use strict';
    var forge = require('forge.min'),
        AbstractCryptoService = require('src/abstract-crypto');

    // TODO create constructor
    // store keys locally
    // encrypt / decrypt public methods
    // public API
    function AesCryptoService(key) {
        if (!(this instanceof AesCryptoService)) {
            throw new TypeError("AesCryptoService constructor cannot be called as a function.");
        }
        this.key = key;
        this.abstractCryptoService = AbstractCryptoService;
    };

    AesCryptoService.BLOCK_CIPHER_KEY_SIZE = 16;

    AesCryptoService.prototype = {
        constructor: AesCryptoService,

        // create a block ciphertext from plaintext
        encrypt: function(plaintext) {
            var iv = forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE);
            var ciphertext = this.abstractCryptoService.encrypt(this.key, iv, plaintext);
            return {
                iv: btoa(iv),
                salt: btoa(forge.random.getBytesSync(0)),
                contents: btoa(ciphertext)
            };
        },

        // decrypt a block ciphertext into plaintext
        decrypt: function(blockCiphertext) {
            return this.abstractCryptoService.decrypt(this.key, atob(blockCiphertext.iv), atob(blockCiphertext.contents));
        }
    };

    return AesCryptoService;
});