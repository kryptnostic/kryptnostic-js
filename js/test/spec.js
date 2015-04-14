define(['require', 'src/aes-crypto-service', 'src/crypto-service-loader', 'src/credential-factory'], function(require) {
    var PASSWORD = 'crom';
    var AesCryptoService = require('src/aes-crypto-service'),
        CryptoServiceLoader = require('src/crypto-service-loader'),
        CredentialFactory = require('src/credential-factory');


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

    describe('CredentialFactory', function() {
        it("can generate a credential", function() {
            var credentialPair = CredentialFactory.generateCredentialPair(PASSWORD);
            expect(credentialPair).not.toBe(null);
        });

        it("derives correct credentials from valid encrypted salt", function() {
            var expectedCredential = '62d97eeb667d58cc012dbdb40fbcdd6e74980106f5658c4ce2e566bea3f3bc63';
            var encryptedSalt = {
                "iv": "ewcVcNXbhKK463r41DFS2g==",
                "salt": "X0jjTehInQbl5KPK0sj/J9qgu9M=",
                "contents": "6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="
            };
            var derivedCredential = CredentialFactory.deriveCredential("demo", encryptedSalt);
            expect(derivedCredential).toBe(expectedCredential);
        });

        it("derives correct credentials from generated", function() {
            var credentialPair = CredentialFactory.generateCredentialPair(PASSWORD);
            var derivedCredential = CredentialFactory.deriveCredential(PASSWORD, credentialPair.encryptedSalt);
            expect(derivedCredential).toBe(credentialPair.credential);
        });
    });

    describe('crypto services loader test', function() {
        it('can run a test', function() {
            CryptoServiceLoader.get("12");
        });
    });
});