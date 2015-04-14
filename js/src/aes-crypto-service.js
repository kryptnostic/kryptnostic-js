define(function() {
    var BLOCK_CIPHER_ITERATIONS = 128;
    var BLOCK_CIPHER_KEY_SIZE = 16;

    /**
     * Encrypt data using forge AES CTR PKCI5
     */
    var _encrypt = function (key, iv, data) {
        var cipher = forge.cipher.createCipher('AES-CTR', key);
        cipher.start({
            iv: iv
        });
        cipher.update(forge.util.createBuffer(data));
        cipher.finish();
        var encrypted = cipher.output;
        return encrypted;
    }

    /**
     * Decrypt data in a block ciphertext using forge AES CTR PKCI5
     */
    var _decrypt = function (key, iv, encrypted) {
        var decipher = forge.cipher.createDecipher('AES-CTR', key);
        decipher.start({
            iv: iv
        });
        decipher.update(forge.util.createBuffer(encrypted));
        decipher.finish();
        return decipher.output;
    }

    // pbkdf2 key derivation, using sha1
    var derive = function(password, salt, iterations, keySize) {
        var md = forge.sha1.create();
        return forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md);
    }

    return {
        encrypt: _encrypt,
        decrypt: _decrypt,
        derive: derive
    }

});