define(['require', 'forge.min', 'src/abstract-crypto'], function(require) {
    'use strict';
    var Forge = require('forge.min'),
        AbstractCryptoService = require('src/abstract-crypto');

    function PasswordCryptoService(password) {
        if (!(this instanceof PasswordCryptoService)) {
            throw new TypeError("PasswordCryptoService constructor cannot be called as a function.");
        }

        this.password = password;
        this.abstractCryptoService = AbstractCryptoService;
    };

    PasswordCryptoService.BLOCK_CIPHER_ITERATIONS = 128;
    PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE = 16;
    
    // pbkdf2 key derivation, using sha1
    function derive(password, salt, iterations, keySize) {
        var md = Forge.sha1.create();
        return Forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md);
    }

    PasswordCryptoService.prototype = {
        constructor: PasswordCryptoService,

        /**
         * Encrypt data in a block ciphertext.
         */
        encrypt: function(plaintext) {
            var salt = Forge.random.getBytesSync(PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE),
                key = derive(this.password, salt, PasswordCryptoService.BLOCK_CIPHER_ITERATIONS, PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE),
                iv = Forge.random.getBytesSync(PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE);
            return {
                key: btoa(key),
                contents: btoa(this.abstractCryptoService.encrypt(key, iv, plaintext)),
                iv: btoa(iv),
                salt: btoa(salt)
            };
        },

        /**
         * Decrypt data in a block ciphertext.
         */
        decrypt: function(blockCiphertext) {
            var key = derive(this.password, atob(blockCiphertext.salt), PasswordCryptoService.BLOCK_CIPHER_ITERATIONS, PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE);
            var iv = atob(blockCiphertext.iv),
                contents = atob(blockCiphertext.contents);
            return this.abstractCryptoService.decrypt(key, iv, contents);
        },

        _derive: function(password, salt, iterations, keySize) {
        	return derive(password, salt, iterations, keySize);
        }

    };

    return PasswordCryptoService;
});