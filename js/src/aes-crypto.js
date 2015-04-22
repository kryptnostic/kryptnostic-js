define(['require', 'forge.min', 'src/abstract-crypto'], function(require) {
    'use strict';
    var Forge = require('forge.min'),
        AbstractCryptoService = require('src/abstract-crypto');

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
        encrypt: function(plaintext) {
            var iv = Forge.random.getBytesSync(AesCryptoService.BLOCK_CIPHER_KEY_SIZE);
            var ciphertext = this.abstractCryptoService.encrypt(this.key, iv, plaintext);
            return {
                iv: btoa(iv),
                salt: btoa(Forge.random.getBytesSync(0)),
                contents: btoa(ciphertext)
            };
        },
        decrypt: function(blockCiphertext) {
            return this.abstractCryptoService.decrypt(this.key, atob(blockCiphertext.iv), atob(blockCiphertext.contents));
        }
    };

    return AesCryptoService;
});