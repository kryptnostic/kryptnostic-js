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

    resolve: (opts) ->
      if opts.email?
        return @resolveEmail(opts)
      else if opts.realm? and opts.username?
        return @resolveUser(opts)
      else
        log.error('unknown resolution opts', { opts })
        throw new Error 'unknown resolution options'

    resolveEmail: ({ email }) ->
      Promise.resolve()
      .then ->
        validateEmail(email)
        axios({
          url    : getUsersUrl() + '/' + email
          method : 'GET'
        })
      .then (response) ->
        uuid = response.data
        return uuid

    resolveUser: ({ realm, username }) ->
      Promise.resolve()
      .then ->
        axios({
          url    : getUsersUrl() + '/' + realm + '/' + username
          method : 'GET'
        })
      .then (response) ->
        uuid = response.data
        return uuid

  return UserDirectoryApi
