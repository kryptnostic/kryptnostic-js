define 'kryptnostic.user-directory-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
], (require) ->

  axios         = require 'axios'
  Promise       = require 'bluebird'
  Logger        = require 'kryptnostic.logger'
  Configuration = require 'kryptnostic.configuration'

  getUsersUrl   = -> Configuration.get('heraclesUrl') + '/directory/users'

  log = Logger.get('UserDirectoryApi')

  DEFAULT_HEADER = { 'Content-Type' : 'application/json' }

  validateEmail = (email) ->
    if _.isEmpty(email)
      log.error('illegal email address', email)
      throw new Error 'illegal email address'

  #
  # HTTP calls for the /directory endpoint of Heracles.
  # Author: rbuckheit
  #
  class UserDirectoryApi

    resolve: ({ email }) ->
      Promise.resolve()
      .then ->
        validateEmail(email)
        axios({
          url    : getUsersUrl() + '/email/' + email
          method : 'GET'
        })
      .then (response) ->
        log.info('response', response)
        uuid = response.data
        if uuid is 'null' or !uuid
          return undefined
        else
          return uuid

  return UserDirectoryApi
