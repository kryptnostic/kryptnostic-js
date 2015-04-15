define(['require', 'forge.min'], function(require) {
    'use strict';
    var forge = require('forge.min');


    function encrypt(key, iv, plaintext) {
        var cipher = forge.cipher.createCipher('AES-CTR', key);
        cipher.start({
            iv: iv
        });
        cipher.update(forge.util.createBuffer(plaintext));
        cipher.finish();
        return cipher.output.data;
    };

    function decrypt(key, iv, ciphertext) {
    	debugger
        var decipher = forge.cipher.createDecipher('AES-CTR', key);
        decipher.start({
            iv: iv
        });
        decipher.update(forge.util.createBuffer(ciphertext));
        decipher.finish();
        return decipher.output.data;
    };

    return {
        encrypt: encrypt,
        decrypt: decrypt
    };
});