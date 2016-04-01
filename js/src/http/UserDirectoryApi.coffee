# coffeelint: disable=cyclomatic_complexity

define 'kryptnostic.user-directory-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
  'kryptnostic.caching-service'
  'kryptnostic.requests'
  'kryptnostic.validators'
], (require) ->
  axios         = require 'axios'
  Promise       = require 'bluebird'
  Logger        = require 'kryptnostic.logger'
  Configuration = require 'kryptnostic.configuration'
  Cache         = require 'kryptnostic.caching-service'
  Requests      = require 'kryptnostic.requests'
  Validators    = require 'kryptnostic.validators'

  getUserUrl   = -> Configuration.get('heraclesUrlV2') + '/directory/user'
  getUsersUrl  = -> Configuration.get('heraclesUrlV2') + '/directory/users'
  usersInRealmUrl = -> Configuration.get('servicesUrlV2') + '/directory'
  setFirstLoginUrl = -> Configuration.get('heraclesUrlV2') + '/directory/setlogin'

  log = Logger.get('UserDirectoryApi')

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  { validateUuids } = Validators

  validateEmail = (email) ->
    if _.isEmpty(email)
      log.error('illegal email address', email)
      throw new Error 'illegal email address'

  validateUuid = (uuid) ->
    if _.isEmpty(uuid)
      log.error('illegal uuid', uuid)
      throw new Error 'illegal uuid'

  #
  # HTTP calls for the /directory endpoint of Heracles.
  # Author: rbuckheit
  #
  class UserDirectoryApi

    getUserName: ( uuid ) =>
      @getUser( uuid )
      .then (user) ->
        return user.name

    resolve: ({ email }) ->
      Promise.resolve()
      .then ->
        validateEmail(email)
        axios({
          url    : getUserUrl() + '/email/' + email
          method : 'GET'
        })
      .then (response) ->
        uuid = response.data
        if uuid is 'null' or !uuid
          return undefined
        else
          return uuid

    getUser: (uuid) ->
      cached = Cache.get( Cache.USERS, uuid )
      if cached?
        return Promise.resolve()
        .then ->
          return cached
      return Promise.resolve()
      .then ->
        validateUuid(uuid)
        axios({
          url    : getUserUrl() + '/' + uuid
          method : 'GET'
        })
      .then (axiosResponse) ->
        if axiosResponse? and axiosResponse.data?
          user = axiosResponse.data
          Cache.store(Cache.USERS, uuid, user)
          return user
        else
          return null

    getUsers: ( initialUUIDs ) ->

      if not validateUuids(initialUUIDs)
        return Promise.resolve([])

      searchResults = Cache.search( Cache.USERS, initialUUIDs )
      uuids = searchResults['uncached']
      cached = searchResults['cached']

      if uuids and uuids.length == 0
        return Promise.resolve(cached)

      Promise.resolve()
      .then ->
        for uuid in uuids
          validateUuid(uuid)
        axios({
          url    : getUsersUrl()
          method : 'POST'
          data   : uuids
        })
      .then (response) ->
        users = response.data
        if users is 'null' or !users
          return undefined
        for user in users
          Cache.store( Cache.USERS, user.id, user )
        return cached.concat(users)

    getInitializedUsers: ({ realm }) ->
      Promise.resolve(axios(Requests.wrapCredentials({
        url    : usersInRealmUrl() + '/initialized/' + realm
        method : 'GET'
      })))
      .then (response) ->
        uuids = response.data
        return uuids

    notifyFirstLogin: ->
      Promise.resolve(axios(
        Requests.wrapCredentials({
          url: setFirstLoginUrl()
          method: 'POST'
        })
      ))

  return UserDirectoryApi
