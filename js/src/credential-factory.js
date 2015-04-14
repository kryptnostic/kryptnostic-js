define(['src/aes-crypto-service', 'forge.min'], function(AesCryptoService, forge) {
    var DEFAULT_ITERATIONS = 1000;
    var DEFAULT_KEY_SIZE = 32;

    // Default password derivation
    function deriveDefault(password, salt) {
        return forge.util.bytesToHex(AesCryptoService.derive(password, salt, DEFAULT_ITERATIONS, DEFAULT_KEY_SIZE));
    }

    /**
     * Generate a new credential, encrypted salt pair from a plaintext password.
     */
    function generateCredentialPair(password) {
        var salt = forge.random.getBytesSync(DEFAULT_KEY_SIZE);
        var credential = deriveDefault(password, salt);
        var encryptedSalt = AesCryptoService.encryptBlock(password, salt);
        return {
            credential: credential,
            encryptedSalt: encryptedSalt
        }
    }

    /**
     * Derive credential from plaintext password and encrypted salt.
     */
    function deriveCredential(password, encryptedSalt) {
        var salt = AesCryptoService.decryptBlock(password, encryptedSalt);
        return deriveDefault(password, salt);
    }

    // Public API
    return {
        generateCredentialPair: generateCredentialPair,
        deriveCredential: deriveCredential
    }
});