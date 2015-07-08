
define [
  'require'
  'soteria.abstract-crypto-service'
], (require) ->

  AbstractCryptoService = require('soteria.abstract-crypto-service')

  PASSWORD              = 'crom'

  describe 'AbstractCryptoService', ->

    cryptoService = new AbstractCryptoService({ algorithm: 'AES', mode: 'CTR' })

    it 'should decrypt known-good values correctly', ->
      decrypted = cryptoService.decrypt(atob("5wb/Vhk7dmM6jvCgC1Lltg=="),
        atob("ewcVcNXbhKK463r41DFS2g=="),
        atob("6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="))
      expect(decrypted).toBe("¢búð)lÚèKwz'öOXfþP¦ã¾þlTíMY")

    it 'should be able to decrypt what it encrypts', ->
      plaintext = "may the force be with you"
      key = "5wb/Vhk7dmM6jvCgC1Lltg=="
      iv = "ewcVcNXbhKK463r41DFS2g=="
      encrypted = cryptoService.encrypt(key, iv, plaintext)
      decrypted = cryptoService.decrypt(key, iv, encrypted)
      expect(decrypted).toBe(plaintext)
