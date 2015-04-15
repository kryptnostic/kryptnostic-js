define(['require', 'src/aes-crypto','src/password-crypto', 'src/crypto-service-loader'], function(require) {
    var PASSWORD = 'crom';
    var AesCryptoService = require('src/aes-crypto'),
        CryptoServiceLoader = require('src/crypto-service-loader'),
        PasswordCryptoService = require('src/password-crypto');


    describe('password crypto class', function() {
        // decrypt known good
        it('decrypts a known-good encrypted block', function() {        
            var cryptoService = new PasswordCryptoService('demo');
            var blockCiphertext = {
                "iv": "ewcVcNXbhKK463r41DFS2g==",
                "salt": "X0jjTehInQbl5KPK0sj/J9qgu9M=",
                "contents": "6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="
            };
            var decrypted = cryptoService.decrypt(blockCiphertext);
            expect(decrypted).toBe("¢búð)lÚèKwz'öOXfþP¦ã¾þlTíMY");
        });

        // decrypt encrypted
        it('decrypts an encrypted value', function() {
            var cryptoService = new PasswordCryptoService(PASSWORD);
            var value = "some text content here!";
            var encrypted = cryptoService.encrypt(value);
            var decrypted = cryptoService.decrypt(encrypted);
            expect(decrypted).toBe(value);
        });

        // derive matches known good
        it('derives key correctly', function() {
            var cryptoService = new PasswordCryptoService(PASSWORD);
            var key = cryptoService._derive('demo', "salt", 128, 16);
            expect(btoa(key)).toBe("EX3hMH7vvRVCzE/HA2liSw==");
        });

    });

    describe('AES crypto class', function() {

    });

    describe('RSA crypto class', function() {

    });

    describe('crypto services loader', function() {
        it('can run a test', function() {
             CryptoServiceLoader.get("12");
        });
    });
});