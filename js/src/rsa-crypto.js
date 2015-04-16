define(['require', 'forge.min'], function(require) {
    'use strict';

    var Forge = require('forge.min');

    // takes in Forge private and public key objects
    function RsaCryptoService(privateKey, publicKey) {
        if (!(this instanceof RsaCryptoService)) {
            throw new TypeError("RsaCryptoService constructor cannot be called as a function.");
        }
        this.privateKey = privateKey;
        this.publicKey = publicKey;
    };

    RsaCryptoService.prototype = {
        constructor: RsaCryptoService,

        encrypt: function(plaintext) {
            var encrypted = this.publicKey.encrypt(plaintext, 'RSA-OAEP', {
                md: Forge.md.sha1.create()
            });
            return encrypted;
        },

        decrypt: function(ciphertext) {
            var decrypted = this.privateKey.decrypt(encrypted, 'RSA-OAEP', {
                md: forge.md.sha1.create()
            });
            return decrypted;
        }
    };

    return RsaCryptoService;

});