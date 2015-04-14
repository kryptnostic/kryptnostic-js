'use strict';

require.config({
    //By default load any module IDs from js/lib
    baseUrl: 'js/lib',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        src: '../src'
    }
});

require(['src/crypto-service-loader'],
    function(cryptoServiceLoader) {
        console.log(cryptoServiceLoader);
        cryptoServiceLoader.get("0ae1f7f8-495a-46c8-8f9e-48c1e12afcdc");
    });

// var KRYPTNOSTIC = (function($, forge) {

//     function AesCryptoService(key, cypher) {
//         this.key = key;
//         this.cypher = cypher;
//     };

//     AesCryptoService.prototype = {
//         var BLOCK_CIPHER_ITERATIONS = 128;
//         var BLOCK_CIPHER_KEY_SIZE = 16;

//         /**
//          * Encrypt data using forge AES CTR PKCI5
//          */
//         function _encrypt(key, iv, data) {
//             var cipher = forge.cipher.createCipher('AES-CTR', key);
//             cipher.start({
//                 iv: iv
//             });
//             cipher.update(forge.util.createBuffer(data));
//             cipher.finish();
//             var encrypted = cipher.output;
//             return encrypted;
//         }

//         /**
//          * Decrypt data in a block ciphertext using forge AES CTR PKCI5
//          */
//         function _decrypt(key, iv, encrypted) {
//             var decipher = forge.cipher.createDecipher('AES-CTR', key);
//             decipher.start({
//                 iv: iv
//             });
//             decipher.update(forge.util.createBuffer(encrypted));
//             decipher.finish();
//             return decipher.output;
//         }

//         // pbkdf2 key derivation, using sha1
//         function derive(password, salt, iterations, keySize) {
//             var md = forge.sha1.create();
//             return forge.pkcs5.pbkdf2(password, salt, iterations, keySize, md);
//         }

//     };

//     PasswordCryptoService.prototype = Object.create(AesCryptoService.prototype);

//     PasswordCryptoService.prototype

//     {


//         /**
//          * Encrypt data in a block ciphertext.
//          */
//         function encryptBlock(password, data) {
//             var salt = forge.random.getBytesSync(BLOCK_CIPHER_KEY_SIZE);
//             var key = derive(password, salt, BLOCK_CIPHER_ITERATIONS, BLOCK_CIPHER_KEY_SIZE);
//             var iv = forge.random.getBytesSync(BLOCK_CIPHER_KEY_SIZE);
//             return {
//                 key: btoa(key),
//                 contents: btoa(_encrypt(key, iv, data).data),
//                 iv: btoa(iv),
//                 salt: btoa(salt)
//             };
//         }

//         /**
//          * Decrypt data in a block ciphertext.
//          */
//         function decryptBlock(password, data) {
//             var key = derive(password, atob(data.salt), BLOCK_CIPHER_ITERATIONS, BLOCK_CIPHER_KEY_SIZE);
//             var iv = atob(data.iv);
//             var contents = atob(data.contents);
//             return _decrypt(key, iv, contents).data;
//         }
//     };

//     // crypto service loader
//     var krypt = {};

//     krypt.getCryptoService = function(id) {

//     };

//     // AES crypto services
//     krypt.setCryptoService = function(id, cryptoService) {

//     };

//     // kryptnostic.crypto.password. encrypt / decrypt
//     //            .crypto.aes encrypt(id, object) / decrypt (id, object)
//     //            .crypto.rsa encrypt(object) decrypt(object)
//     // password crypto service
//     // rsa crypto service
//     // aes crypto service

// }());