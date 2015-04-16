define(['require', 'forge.min'], function(require) {
    'use strict';

    var Forge = require('forge.min');

    // takes in PEM formatted priv and pub keys
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

        },

        decrypt: function(ciphertext) {

        },

    };

    return RsaCryptoService;

});