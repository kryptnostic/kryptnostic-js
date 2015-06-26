define('soteria.crypto-service-loader', ['require', 'jquery', 'cookies', 'forge.min', 'pako', 'src/utils', 'src/password-crypto', 'src/rsa-crypto', 'src/aes-crypto'], function(require) {
    'use strict';
    var jquery = require('jquery'),
        Cookies = require('cookies'),
        Forge = require('forge.min'),
        Pako = require('pako'),
        PasswordCryptoService = require('src/password-crypto'),
        RsaCryptoService = require('src/rsa-crypto'),
        AesCryptoService = require('src/aes-crypto'),
        SecurityUtils = require('src/utils');

    var BASE_URL = 'http://localhost:8081/v1',
        DIR_URL = '/directory',
        PUB_URL = '/public',
        PRIV_URL = '/private',
        OBJ_URL = '/object',
        INT_SIZE = 4;

    function CryptoServiceLoader(password) {
        if (!(this instanceof CryptoServiceLoader)) {
            throw new TypeError("CryptoServiceLoader constructor cannot be called as a function.");
        }
        this.passwordCryptoService = new PasswordCryptoService(password);
    };

    CryptoServiceLoader.prototype = {
        constructor: CryptoServiceLoader
    };

    CryptoServiceLoader.prototype.getPasswordCryptoService = function() {
        return this.passwordCryptoService;
    };

    CryptoServiceLoader.prototype.getRsaCryptoService = function() {
        var deferred = new jquery.Deferred();
        if (typeof this.rsaCryptoService === 'undefined') {
            loadRsaKeys.call(this).then(function(keypair) {
                this.rsaCryptoService = new RsaCryptoService(keypair.privateKey, keypair.publicKey);
                deferred.resolve(this.rsaCryptoService);
            }.bind(this));
        } else {
            deferred.resolve(this.rsaCryptoService);
        }
        return deferred.promise();
    };

    CryptoServiceLoader.prototype.getObjectCryptoService = function(id) {
        var deferred = new jquery.Deferred();
        var privateKey;
        var cryptoServiceResponse;
        jquery.when(
            this.getRsaCryptoService(),
            loadCryptoService(id)
        ).then(function(rsaCryptoService, cryptoServiceResponse) {
            var deflatedCryptoService = rsaCryptoService.decrypt(atob(cryptoServiceResponse[0].data));
            var buffer = Forge.util.createBuffer(deflatedCryptoService, 'raw');
            buffer.getBytes(INT_SIZE); // remove the prepended length integer
            var compBytes = buffer.getBytes(buffer.length());
            var decompressedCryptoService = JSON.parse(Pako.inflate(compBytes, {
                to: 'string'
            })); // inflate crypto service
            var objectCryptoService = new AesCryptoService(atob(decompressedCryptoService.key)); // create AesCryptoService

            deferred.resolve(objectCryptoService);
        }.bind(this));
        return deferred.promise();
    };

    CryptoServiceLoader.prototype.setObjectCryptoService = function(id, cryptoService) {
        // TODO
    };

    // Helper functions
    function loadRsaKeys() {
        var deferred = new jquery.Deferred();
        var request = jquery.ajax(SecurityUtils.wrapRequest({
            url: BASE_URL + DIR_URL + PRIV_URL,
            type: 'GET'
        }));

        var resolveRsaKeys = function(blockCiphertext) {
            var privateKeyBytes  = this.getPasswordCryptoService().decrypt(blockCiphertext);
            var privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw');
            var privateKeyAsn1   = Forge.asn1.fromDer(privateKeyBuffer);
            var privateKey       = Forge.pki.privateKeyFromAsn1(privateKeyAsn1);
            var publicKey        = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e);

            deferred.resolve({
                privateKey: privateKey,
                publicKey: publicKey
            });
        };

        request.done(resolveRsaKeys.bind(this));

        request.fail(function() {
            deferred.reject();
        });

        return deferred.promise();
    };

    // TODO cache object crypto services locally
    function loadCryptoService(id) {
        return jquery.ajax(SecurityUtils.wrapRequest({
            url: BASE_URL + DIR_URL + OBJ_URL + '/' + id,
            type: 'GET'
        }));
    };

    return CryptoServiceLoader;
});