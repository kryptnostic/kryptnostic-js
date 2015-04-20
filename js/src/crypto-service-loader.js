define(['require', 'jquery', 'forge.min', 'pako', 'src/password-crypto', 'src/rsa-crypto', 'src/aes-crypto'], function(require) {
    'use strict';
    var jquery = require('jquery'),
        Forge = require('forge.min'),
        Pako = require('pako'),
        PasswordCryptoService = require('src/password-crypto'),
        RsaCryptoService = require('src/rsa-crypto'),
        AesCryptoService = require('src/aes-crypto');

    var BASE_URL = 'http://localhost:8081/v1',
        DIR_URL = '/directory',
        PUB_URL = '/public',
        PRIV_URL = '/private',
        OBJ_URL = '/object';


    function CryptoServiceLoader() {
        if (!(this instanceof CryptoServiceLoader)) {
            throw new TypeError("CryptoServiceLoader constructor cannot be called as a function.");
        }
    };

    // async wrapper in case keys have not yet instantiated from constructor call.
    function getRsaCryptoService() {
        var deferred = new jquery.Deferred();
        if (typeof this.rsaCryptoService === 'undefined') {
            loadRsaKeys().then(function(keypair) {
                this.rsaCryptoService = new RsaCryptoService(keypair.privateKey, keypair.publicKey);
                deferred.resolve(this.rsaCryptoService);
            }.bind(this));
        } else {
            deferred.resolve(this.rsaCryptoService);
        }
        return deferred.promise();
    };

    function loadRsaKeys() {
        var deferred = new jquery.Deferred(),
            passwordCryptoService = new PasswordCryptoService("demo");
        var request = jquery.ajax({
            url: BASE_URL + DIR_URL + PRIV_URL,
            type: 'GET',
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-Kryptnostic-Principal', 'krypt|vader');
                xhr.setRequestHeader('X-Kryptnostic-Credential', 'fd81f8a7af1cb138bdce93350768b2b453ccf238908091501b05fe25616168b0');
            }
        });

        request.done(function(blockCiphertext) {
            var privateKeyBytes = passwordCryptoService.decrypt(blockCiphertext);
            var privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw');
            var privateKeyAsn1 = Forge.asn1.fromDer(privateKeyBuffer);
            var privateKey = Forge.pki.privateKeyFromAsn1(privateKeyAsn1);
            var publicKey = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e);

            deferred.resolve({
                privateKey: privateKey,
                publicKey: publicKey
            });
        });

        request.fail(function() {
            deferred.reject();
        });

        return deferred.promise();
    };

    // TODO cache locally
    function loadCryptoService(id) {
        return jquery.ajax({
            url: BASE_URL + DIR_URL + OBJ_URL + '/' + id,
            type: 'GET',
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-Kryptnostic-Principal', 'krypt|vader');
                xhr.setRequestHeader('X-Kryptnostic-Credential', 'fd81f8a7af1cb138bdce93350768b2b453ccf238908091501b05fe25616168b0');
            }
        });
    };

    CryptoServiceLoader.prototype = {
        constructor: CryptoServiceLoader,
        get: function(id) {
            var deferred = new jquery.Deferred();
            var privateKey;
            var cryptoServiceResponse;
            jquery.when(
                getRsaCryptoService.call(this),
                loadCryptoService(id)
            ).then(function(rsaCryptoService, cryptoServiceResponse) {
                // decrypt crypto service
                var deflatedCryptoService = rsaCryptoService.decrypt(atob(cryptoServiceResponse[0].data));
                var buffer = Forge.util.createBuffer(deflatedCryptoService, 'raw');
                // remove the prepended length integer
                buffer.getBytes(4);
                // inflate crypto service
                var compBytes = buffer.getBytes(buffer.length());
                var decompressedCryptoService = JSON.parse(Pako.inflate(compBytes, { to: 'string' }));
                // create AesCryptoService
                var objectCryptoService = new AesCryptoService(atob(decompressedCryptoService.key));
                deferred.resolve(objectCryptoService);
            }.bind(this));
            return deferred.promise();
        },
        set: function(cryptoService) {
            // RSA encrypt portions of request
            // send request
        }
    };


    return CryptoServiceLoader;
});