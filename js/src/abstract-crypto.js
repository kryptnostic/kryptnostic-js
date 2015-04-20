define(['require', 'forge.min'], function(require) {
    'use strict';
    var Forge = require('forge.min');


    function encrypt(key, iv, plaintext) {
        var cipher = Forge.cipher.createCipher('AES-CTR', key);
        cipher.start({
            iv: iv
        });
        cipher.update(Forge.util.createBuffer(plaintext));
        cipher.finish();
        return cipher.output.data;
    };

    function decrypt(key, iv, ciphertext) {
        var decipher = Forge.cipher.createDecipher('AES-CTR', key);
        decipher.start({
            iv: iv
        });
        decipher.update(Forge.util.createBuffer(ciphertext));
        decipher.finish();
        return decipher.output.data;
    };

    return {
        encrypt: encrypt,
        decrypt: decrypt
    };
});