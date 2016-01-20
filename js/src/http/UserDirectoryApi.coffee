define 'kryptnostic.user-directory-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.logger'
  'kryptnostic.configuration'
  'kryptnostic.caching-service'
  'kryptnostic.requests'
], (require) ->

  axios         = require 'axios'
  Promise       = require 'bluebird'
  Logger        = require 'kryptnostic.logger'
  Configuration = require 'kryptnostic.configuration'
  Cache         = require 'kryptnostic.caching-service'
  Requests      = require 'kryptnostic.requests'

  getUserUrl   = -> Configuration.get('heraclesUrlV2') + '/directory/user'
  getUsersUrl  = -> Configuration.get('heraclesUrlV2') + '/directory/users'
  usersInRealmUrl = -> Configuration.get('servicesUrl') + '/directory'

  log = Logger.get('UserDirectoryApi')

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

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
        log.info('response', response)
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
          log.info('getUser', user)
          Cache.store(Cache.USERS, uuid, user)
          return user
        else
          return null

    getUsers: ( initialUUIDs ) ->
      searchResults = Cache.search( Cache.USERS, initialUUIDs )
      uuids = searchResults['uncached']
      cached = searchResults['cached']
      if uuids.length == 0
        return Promise.resolve()
        .then ->
          return cached
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
        log.info('getUsers', users)
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

  return UserDirectoryApi
