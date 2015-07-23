define [
  'require'
  'kryptnostic.password-crypto-service'
], (require) ->

  PasswordCryptoService = require 'kryptnostic.password-crypto-service'

  PASSWORD_1 = 'crom'
  PASSWORD_2 = 'demo'

  describe 'PasswordCryptoService', ->

    it 'should decrypt a known-good encrypted block', ->
      cryptoService = new PasswordCryptoService()
      blockCiphertext = {
        iv       : 'ewcVcNXbhKK463r41DFS2g==',
        salt     : 'X0jjTehInQbl5KPK0sj/J9qgu9M=',
        contents : '6veqEBl0TNxneQfnfpLbeRey5Yfe4oIKOqrepHn5vac='
      }
      decrypted = cryptoService.decrypt(blockCiphertext, PASSWORD_2)
      expect(decrypted).toBe('¢búð)lÚèKwz\'öOXfþP¦ã¾þlTíMY')

    it 'should decrypt an encrypted value', ->
      cryptoService = new PasswordCryptoService()
      value         = 'some text content here!'
      encrypted     = cryptoService.encrypt(value, PASSWORD_1)
      decrypted     = cryptoService.decrypt(encrypted, PASSWORD_1)
      expect(decrypted).toBe(value)

    it 'should derive a key correctly', ->
      cryptoService = new PasswordCryptoService()
      key = cryptoService._derive(PASSWORD_2, 'salt', 128, 16)
      expect(btoa(key)).toBe('EX3hMH7vvRVCzE/HA2liSw==')
