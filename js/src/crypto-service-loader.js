define(['require', 'jquery', 'forge.min', 'src/password-crypto', 'src/rsa-crypto'], function(require) {
    var jquery = require('jquery'),
        Forge = require('forge.min'),
        PasswordCryptoService = require('src/password-crypto'),
        RsaCryptoService = require('src/rsa-crypto');

    var BASE_URL = 'http://localhost:8081/v1',
        DIR_URL = '/directory',
        PUB_URL = '/public',
        PRIV_URL = '/private',
        OBJ_URL = '/object';


    function CryptoServiceLoader() {
        if (!(this instanceof CryptoServiceLoader)) {
            throw new TypeError("CryptoServiceLoader constructor cannot be called as a function.");
        }
        loadRsaKeys().done(function(privateKey, publicKey) {
            this.rsaCryptoService = new RsaCryptoService(privateKey, publicKey);
        });
        this.rsaCryptoService = getCryptoService();
    };

    function loadRsaKeys() {
        var deferred = jquery.Deferred(),
            passwordCryptoService = new PasswordCryptoService("demo");
        jquery.when(
            loadPrivateKey(),
            loadPublicKey()
        ).then(function(encryptedPrivateKey, encryptedPublicKey) {
            var privateKeyBytes = passwordCryptoService.decrypt(encryptedPrivateKey[0]);
            var privateKeyBuffer = Forge.util.createBuffer(privateKeyBytes, 'raw');
            var privateKeyAsn1 = Forge.asn1.fromDer(privateKeyBuffer);
            var privateKey = Forge.pki.privateKeyFromAsn1(privateKeyAsn1);
            // decrypt the RSA keys with password service
            // create a forge RSA key for each
            deferred.resolve(privateKey);
        });

    return deferred.promise;
};

function loadPrivateKey() {
    return jquery.ajax({
        url: BASE_URL + DIR_URL + PRIV_URL,
        type: 'GET',
        beforeSend: function(xhr) {
            xhr.setRequestHeader('X-Kryptnostic-Principal', 'krypt|vader');
            xhr.setRequestHeader('X-Kryptnostic-Credential', 'fd81f8a7af1cb138bdce93350768b2b453ccf238908091501b05fe25616168b0');
        },
        success: function(data) {
            return data;
        }
    });
};

function loadPublicKey() {
    // get current user from document cookies, throw error if not logged in
    var name = 'vader';
    // TODO replace with document.cookie, index into. 
    return jquery.ajax({
        url: BASE_URL + DIR_URL + PUB_URL + '/' + name,
        type: 'GET',
        beforeSend: function(xhr) {
            xhr.setRequestHeader('X-Kryptnostic-Principal', 'krypt|vader');
            xhr.setRequestHeader('X-Kryptnostic-Credential', 'fd81f8a7af1cb138bdce93350768b2b453ccf238908091501b05fe25616168b0');
        },
        success: function(data) {
            return data;
        }
    });
};

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
        var privateKey;
        var cryptoServiceResponse;
        jquery.when(
            getRsaCryptoService(),
            loadCryptoService(id)
        ).then(function(rsaCryptoService, cryptoServiceResponse) {
            console.log(rsaCryptoService);
            // create RSA crypto service with privateKey
            console.log(cryptoServiceResponse);
            // decrypt crypto service, create AES service
        });
    },
    set: function(cryptoService) {
        // RSA encrypt portions of request
        // send request
    }
};


return CryptoServiceLoader;
});