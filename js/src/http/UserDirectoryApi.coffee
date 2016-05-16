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

  getUserUrl   = -> Configuration.get('heraclesUrl') + '/directory/user'
  getUsersUrl  = -> Configuration.get('heraclesUrl') + '/directory/users'
  usersInRealmUrl = -> Configuration.get('heraclesUrl') + '/directory'
  setFirstLoginUrl = -> Configuration.get('heraclesUrl') + '/directory/setlogin'
  getConfirmationUrl = -> Configuration.get('heraclesUrl') + '/registration/confirmation/resend'
  getVerificationUrl = (uuid, token) -> Configuration.get('heraclesUrl') +
      '/registration/verification/' + uuid + '/' + token
  getUserIdFromEmail = (email) -> Configuration.get('heraclesUrl') + '/directory/validate/sharing/email/' + email
  getUserSettingUrl = (userSetting) -> getUserUrl() + '/setting/' + userSetting

  log = Logger.get('UserDirectoryApi')

  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

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

    getUserIdFromEmail: (email) ->

      if _.isEmpty(email)
        return Promise.resolve(null)

      Promise.resolve(
        axios(
          Requests.wrapCredentials({
            method : 'GET',
            url    : getUserIdFromEmail(email)
          })
        )
      )
      .then (axiosResponse) ->
        if axiosResponse and axiosResponse.data
          # axiosResponse.data == java.util.UUID
          return axiosResponse.data
        else
          return null
      .catch (axiosError) ->
        kjsError = {
          status: axiosError.status
        }
        if axiosError.status == 404
          kjsError.message = 'USER_DOES_NOT_EXIST'
          return Promise.reject(kjsError)
        else if axiosError.status == 403
          kjsError.message = 'SHARING_WITH_USER_BLOCKED'
          return Promise.reject(kjsError)
        else
          kjsError.message = JSON.stringify(axiosError.data)
          return Promise.reject(kjsError)

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

    getUserSetting: (setting) ->
      Promise.resolve(axios(
        Requests.wrapCredentials({
          url: getUserSettingUrl(setting)
          method: 'GET'
        })
      ))

    addUserSetting: (uuid, setting) ->
      Promise.resolve(axios(
        Requests.wrapCredentials({
          url: getUserSettingUrl(setting)
          headers: DEFAULT_HEADERS
          method: 'PUT'
          data: [uuid]
        })
      ))

    removeUserSetting: (uuid, setting) ->
      Promise.resolve(axios(
        Requests.wrapCredentials({
          url: getUserSettingUrl(setting)
          headers: DEFAULT_HEADERS
          method: 'DELETE'
          data: [uuid]
        })
      ))

    resendConfirmationEmail: ->
      Promise.resolve(axios(
        Requests.wrapCredentials({
          url: getConfirmationUrl()
          method: 'GET'
        })
      ))

    sendConfirmationToken: (uuid, token) ->
      Promise.resolve(axios(
        Requests.wrapCredentials({
          url: getVerificationUrl(uuid, token)
          method: 'GET'
        })
      ))

  return UserDirectoryApi
