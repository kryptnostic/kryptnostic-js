
define(['require', 'forge.min', 'src/abstract-crypto', 'src/aes-crypto', 'src/password-crypto', 'src/rsa-crypto', 'src/crypto-service-loader'], function(require) {

  var AesCryptoService      = require('src/aes-crypto');
  var CryptoServiceLoader   = require('src/crypto-service-loader');
  var PasswordCryptoService = require('src/password-crypto');
  var RsaCryptoService      = require('src/rsa-crypto');
  var Forge                 = require('forge.min');
  var AbstractCryptoService = require('src/abstract-crypto');

  var PASSWORD = 'crom';

  describe('abstract crypto service', function() {
    var cryptoService = new AbstractCryptoService({ algorithm: 'AES', mode: 'CTR' });

    it('decrypts known-good values correctly', function() {
      var decrypted = cryptoService.decrypt(atob("5wb/Vhk7dmM6jvCgC1Lltg=="), atob("ewcVcNXbhKK463r41DFS2g=="), atob("6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="));
      expect(decrypted).toBe("¢búð)lÚèKwz'öOXfþP¦ã¾þlTíMY");
    });

    it('can decrypt what it encrypts', function() {
      var plaintext = "may the force be with you",
        encrypted = cryptoService.encrypt("5wb/Vhk7dmM6jvCgC1Lltg==", "ewcVcNXbhKK463r41DFS2g==", plaintext),
        decrypted = cryptoService.decrypt("5wb/Vhk7dmM6jvCgC1Lltg==", "ewcVcNXbhKK463r41DFS2g==", encrypted);
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
      var cypher = {
        algorithm: 'AES',
        mode: 'CTR'
      };
      var cryptoService = new AesCryptoService(cypher, key),
        plaintext = "star wars NOPE yoda YUP";
      debugger
      var blockCiphertext = cryptoService.encrypt(plaintext),
        decrypted = cryptoService.decrypt(blockCiphertext);
      expect(decrypted).toBe(plaintext);
    });
  });

  describe('RSA crypto class', function() {
    it('correctly decrypts a known-good ciphertext', function() {
      var privateKey = Forge.pki.privateKeyFromPem("-----BEGIN RSA PRIVATE KEY-----\
        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\
        -----END RSA PRIVATE KEY-----");
      var publicKey = Forge.pki.setRsaPublicKey(privateKey.n, privateKey.e);
      var cryptoService = new RsaCryptoService(privateKey, publicKey);
      var ciphertext = atob("Xz7+Dl864pUmMKDcIDC2gaE3PWpTOqnNv/LNgxAEjpgonHfW8sEyjQGzTDVoxuq4GJH+TBRyT58BHvZeboFUsBiLKFarD1el4zEcRHaRoql0ysmv7Xxx7PyGkRzLH+UqyV/6Gs5PSixIyN5GYBi8uKqv3WC8mLXHf14lyh3QZlRoBswNYBmchMO10RXLvGiKZWLdb+/nLZDgMvn5x/toogrYDncnzI5qoTGw30fTf3JPSYzL4LNP3XzpN5QNwUUbKvzuyfQNrH/k8l6eTCZURnyS5FUkvkIFpYc9DYmeB40nVxlMQfm+HryQWG1MgWAuhLota3kUDNkpMXUnk5CAHeoVjsG1xGF5blnjxqtN3jcJ8MNRcZUzdJaSG0XnVKs42xP7Q9O9FS4gw/uS/Z+PmYd2Zz7Jl2JNVZJWGZIiiL/e+mrzD/jTRX34HU4u+Zkmqq7JMWaDvYKDVbEVJLhPaT6Vhr60SBrlB776EaDYgYUdtAfWdhh9chr7gv8zW9v52HG8POAHqwtmpHAT3rth62Jsk9h9iwvuBbo9SFJzTOreFNCfKcNbLUF60us14BRdiUtX+STpu6WmC8XUCYTD64wZ9VZM8WeLyzEDlcKcKbSTJyE9RwzpABknrxnZNFzTKywsxfcGp+rn0Lx5MBFAwGpZF6JhujGMeFyfLaTL14o=");
      var plaintext = cryptoService.decrypt(ciphertext);
      expect(atob("AAAAcHjaq1ZKrizISC1SsqpWSsxJzy/KLMnIVbJScnQNVtJRys1PSQVynEOCgJyCxJSUzLx0IN8vPwDK1lHKTq0MzqwCqjI0sqgFc4EKorQ9KgNyIqPSQ1PMQyMLwsvNkiO9A21tlWoB454jcQ==")).toBe(plaintext);
    });

    it('can decrypt what it encrypts', function() {
      var keypair = Forge.rsa.generateKeyPair({bits: 1024, e: 0x10001});
      var cryptoService = new RsaCryptoService(keypair.privateKey, keypair.publicKey );
      var plaintext = "my heart is a blue ridge mountain";
      var recovered = cryptoService.decrypt(cryptoService.encrypt(plaintext));
      expect(recovered).toBe(plaintext);
    });
  });

  describe('crypto services loader', function() {

  });
});