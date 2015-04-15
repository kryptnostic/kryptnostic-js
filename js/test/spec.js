define(['require', 'forge.min', 'src/abstract-crypto', 'src/aes-crypto', 'src/password-crypto', 'src/crypto-service-loader'], function(require) {
    var PASSWORD = 'crom';
    var AbstractCryptoService = require('src/abstract-crypto'),
        AesCryptoService = require('src/aes-crypto'),
        CryptoServiceLoader = require('src/crypto-service-loader'),
        PasswordCryptoService = require('src/password-crypto'),
        Forge = require('forge.min');

    describe('abstract crypto service', function() {
        it('decrypts known-good values correctly', function() {
            var decrypted = AbstractCryptoService.decrypt(atob("5wb/Vhk7dmM6jvCgC1Lltg=="), atob("ewcVcNXbhKK463r41DFS2g=="), atob("6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="));
            expect(decrypted).toBe("¢búð)lÚèKwz'öOXfþP¦ã¾þlTíMY");
        });

        it('can decrypt what it encrypts', function() {
            var plaintext = "may the force be with you",
                encrypted = AbstractCryptoService.encrypt("5wb/Vhk7dmM6jvCgC1Lltg==", "ewcVcNXbhKK463r41DFS2g==", plaintext),
                decrypted = AbstractCryptoService.decrypt("5wb/Vhk7dmM6jvCgC1Lltg==", "ewcVcNXbhKK463r41DFS2g==", encrypted);
            expect(decrypted).toBe(plaintext);
        });
    });

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
        it('can decrypt what it encrypts', function() {
            var key = Forge.random.getBytesSync(PasswordCryptoService.BLOCK_CIPHER_KEY_SIZE);
            var cryptoService = new AesCryptoService(key),
                plaintext = "star wars NOPE yoda YUP";
            debugger
            var blockCiphertext = cryptoService.encrypt(plaintext),
                decrypted = cryptoService.decrypt(blockCiphertext);
            expect(decrypted).toBe(plaintext);
        });
    });

    describe('RSA crypto class', function() {
        
    });

    describe('crypto services loader', function() {
        it('can run a test', function() {
            CryptoServiceLoader.get("12");
        });
    });
});