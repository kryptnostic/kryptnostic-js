define(['jquery'], function(jquery) { // depend on AES, RSA and Password services, to instantiate
    var BASE_URL = 'http://localhost:8081/v1';
    var DIR_URL = '/directory';
    var PUB_URL = '/public';
    var PRIV_URL = '/private';
    var OBJ_URL = '/object';

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

    // function loadPublicKey() {
    //     // get current user from document cookies, throw error if not logged in
    //     var name = 'vader';
    //     // TODO replace with document.cookie, index into. 
    //     // TODO integrate auth more closely, so there is a credential store
    //     // load RSA private key
    //     return jquery.get(BASE_URL + DIR_URL + PUB_URL + '/' + name);
    // };

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

    function getCryptoService(id) {
        var privateKey;
        var cryptoServiceResponse;
        jquery.when(
            loadPrivateKey(), 
            loadCryptoService(id)
        ).then(function(privateKey, cryptoService) {
        	console.log(privateKey);
        	// create RSA crypto service with privateKey
        	console.log(cryptoService);
        	// decrypt crypto service, create AES service
        });
    };

    function setCryptoService(cryptoService) {
        // load RSA pub key
        // encrypt portions of request
        // send request
    };


    return {
        get: getCryptoService,
        put: setCryptoService
    }
});