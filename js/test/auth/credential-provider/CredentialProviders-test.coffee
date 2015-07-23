define [
  'require'
  'forge'
  'kryptnostic.credential-provider.session-storage'
  'kryptnostic.credential-provider.local-storage'
  'kryptnostic.credential-provider.memory'
], (require) ->

  Forge                            = require 'forge'
  SessionStorageCredentialProvider = require 'kryptnostic.credential-provider.session-storage'
  LocalStorageCredentialProvider   = require 'kryptnostic.credential-provider.local-storage'
  InMemoryCredentialProvider       = require 'kryptnostic.credential-provider.memory'

  [
    LocalStorageCredentialProvider,
    SessionStorageCredentialProvider,
    InMemoryCredentialProvider
  ].forEach (CredentialProvider) ->

    {principal, credential, keypair} = {}

    beforeEach ->
      CredentialProvider.destroy()
      principal  = 'krypt|demo'
      credential = 'fake-credential'
      keypair    = Forge.rsa.generateKeyPair({bits: 32, e: 0x10001})

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
