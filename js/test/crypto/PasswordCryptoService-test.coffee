define [
  'require'
  'soteria.password-crypto-service'
], (require) ->

  PasswordCryptoService = require 'soteria.password-crypto-service'

  PASSWORD = 'crom'

  describe 'PasswordCryptoService', ->

    it 'should decrypt a known-good encrypted block', ->
      cryptoService = new PasswordCryptoService('demo')
      blockCiphertext = {
        iv       : "ewcVcNXbhKK463r41DFS2g==",
        salt     : "X0jjTehInQbl5KPK0sj/J9qgu9M=",
        contents : "6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac="
      }
      decrypted = cryptoService.decrypt(blockCiphertext)
      expect(decrypted).toBe("¢búð)lÚèKwz'öOXfþP¦ã¾þlTíMY")

    it 'should decrypt an encrypted value', ->
      cryptoService = new PasswordCryptoService(PASSWORD)
      value         = "some text content here!"
      encrypted     = cryptoService.encrypt(value)
      decrypted     = cryptoService.decrypt(encrypted)
      expect(decrypted).toBe(value)

    it 'should derive a key correctly', ->
      cryptoService = new PasswordCryptoService(PASSWORD)
      key = cryptoService._derive('demo', "salt", 128, 16)
      expect(btoa(key)).toBe("EX3hMH7vvRVCzE/HA2liSw==")
