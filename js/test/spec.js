define(['require', 'src/aes-crypto-service', 'src/crypto-service-loader'], function(require) {
    var PASSWORD = 'crom';
    var AesCryptoService = require('src/aes-crypto-service'),
        CryptoServiceLoader = require('src/crypto-service-loader');


    describe('AES CryptoService', function() {
        // decrypt known good
        it('decrypts a known-good encrypted block', function() {
            var blockCiphertext = {
                "iv": "ewcVcNXbhKK463r41DFS2g==",
                "salt": "X0jjTehInQbl5KPK0sj/J9qgu9M=",
                "contents": "6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="
            };
            var decrypted = AesCryptoService.decryptBlock('demo', blockCiphertext);
            expect(decrypted).toBe("¢búð)lÚèKwz'öOXfþP¦ã¾þlTíMY");
        });

        // decrypt encrypted
        it('decrypts an encrypted value', function() {
            var value = "some text content here!";
            var encrypted = AesCryptoService.encryptBlock(PASSWORD, value);
            var decrypted = AesCryptoService.decryptBlock(PASSWORD, encrypted);
            expect(decrypted).toBe(value);
        });

        // derive matches known good
        it('derives key correctly', function() {
            var key = AesCryptoService.derive('demo', "salt", 128, 16);
            expect(btoa(key)).toBe("EX3hMH7vvRVCzE/HA2liSw==");
        });

    });

    describe('crypto services loader test', function() {
        it('can run a test', function() {
            CryptoServiceLoader.get("12");
        });
    });
});