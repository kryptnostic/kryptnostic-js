define [
  'require'
  'sinon'
  'bluebird'
  'kryptnostic.user-client'
], (require) ->

  UserClient = require 'kryptnostic.user-client'
  sinon      = require 'sinon'
  Promise    = require 'bluebird'

  { userService, loadedUuids } = {}

  MOCK_USER = {
    id   : '1-2-3-4-5-6-7-8-9'
    name : 'christopher wallace'
  }

  beforeEach ->
    loadedUuids = []
    userService = new UserClient()
    sinon.stub(userService.userDirectoryApi, 'getUser', (uuid) ->
      loadedUuids.push(uuid)
      return Promise.resolve(_.cloneDeep(MOCK_USER))
    )

  afterEach ->
    userService.userDirectoryApi.getUser.restore()

  describe 'UserClient', ->

    describe '#loadUser', ->

      it 'should load an uncached user with one api call', (done) ->
        uuid = MOCK_USER.id

        userService.loadUser(uuid)
        .then (user) ->
          expect(user).toEqual(MOCK_USER)
          expect(loadedUuids.length).toBe(1)
          expect(loadedUuids).toEqual([uuid])
          done()

      it 'should load an identical cached user without hitting the api again', (done) ->
        uuid = MOCK_USER.id

        userService.loadUser(uuid)
        .then (user) ->
          expect(user).toEqual(MOCK_USER)
          expect(loadedUuids.length).toBe(1)
          expect(loadedUuids).toEqual([uuid])
          userService.loadUser(uuid)
        .then (user) ->
          expect(user).toEqual(MOCK_USER)
          expect(loadedUuids.length).toBe(1)
          expect(loadedUuids).toEqual([uuid])
          done()
