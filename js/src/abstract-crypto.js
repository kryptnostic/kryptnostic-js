define(['require', 'forge.min'], function(require) {
    'use strict';
    var Forge = require('forge.min');

    function AbstractCryptoService(cypher) {
        if (!(this instanceof AbstractCryptoService)) {
            throw new TypeError("AbstractCryptoService constructor cannot be called as a function.");
        }
        if (!(cypher.algorithm === 'AES' && cypher.mode === 'CTR')) {
            throw "Cypher not implemented.";
        }
        this.algorithm = cypher.algorithm;
        this.mode = cypher.mode;
    };

    AbstractCryptoService.prototype = {
        constructor: AbstractCryptoService,
        encrypt: function(key, iv, plaintext) {
            var cipher = Forge.cipher.createCipher(this.algorithm + '-' + this.mode, key);
            cipher.start({
                iv: iv
            });
            cipher.update(Forge.util.createBuffer(plaintext));
            cipher.finish();
            return cipher.output.data;
        },

        decrypt: function(key, iv, ciphertext) {
            var decipher = Forge.cipher.createDecipher(this.algorithm + '-' + this.mode, key);
            decipher.start({
                iv: iv
            });
            decipher.update(Forge.util.createBuffer(ciphertext));
            decipher.finish();
            return decipher.output.data;
        }
    }

    return AbstractCryptoService;
});