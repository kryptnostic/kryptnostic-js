define [
  'require'
  'forge'
  'soteria.credential-provider.session-storage'
  'soteria.credential-provider.local-storage'
  'soteria.credential-provider.memory'
], (require) ->

  Forge                            = require 'forge'
  SessionStorageCredentialProvider = require 'soteria.credential-provider.session-storage'
  LocalStorageCredentialProvider   = require 'soteria.credential-provider.local-storage'
  InMemoryCredentialProvider       = require 'soteria.credential-provider.memory'

  [
    LocalStorageCredentialProvider,
    SessionStorageCredentialProvider,
    InMemoryCredentialProvider
  ].forEach (CredentialProvider) ->

    {principal, credential, keypair} = {}

    beforeEach ->
      CredentialProvider.destroy()
      id         = Math.floor(Math.random() * 1000)
      principal  = "krypt|demo-#{id}"
      keypair    = Forge.rsa.generateKeyPair({bits: 128, e: 0x10001})
      credential = 'fake-credential'

    afterEach ->
      CredentialProvider.destroy()

    describe CredentialProvider.constructor.name, ->

      describe '#store', ->

        it 'should store a complete credential', ->
          CredentialProvider.store({principal, credential, keypair})

        it 'should store a credential without keypair', ->
          CredentialProvider.store({principal, credential})

        it 'should throw if credential is missing', ->
          expect( -> CredentialProvider.store({principal, keypair}) ).toThrow()

        it 'should throw if principal is missing', ->
          expect( -> CredentialProvider.store({credential, keypair}) ).toThrow()

      describe '#load', ->

        it 'should load all stored credentials', ->
          CredentialProvider.store({principal, credential, keypair})
          loaded = CredentialProvider.load()

          expect(loaded.keypair).toBeDefined()
          expect(loaded.credential).toBe(credential)
          expect(loaded.principal).toBe(principal)

        it 'should throw if user is not authenticated', ->
          expect( -> CredentialProvider.load() ).toThrow()

      describe '#destroy', ->

        it 'should destroy all stored credentials', ->
          CredentialProvider.store({principal, credential, keypair})
          CredentialProvider.destroy()

          expect( -> CredentialProvider.load() ).toThrow()
