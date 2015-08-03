define 'kryptnostic.registration-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
  'kryptnostic.logger'
], (require) ->

  axios         = require 'axios'
  Configuration = require 'kryptnostic.configuration'

  registrationUrl = -> Configuration.get('heraclesUrl') + '/registration/developers'

  log = Logger.get('RegistrationApi')

  #
  # HTTP calls for registration.
  #
  class RegistrationApi

    register: (realm, email, givenName) ->
      Promise.resolve(axios({
        method : 'POST'
        data :
          realm       : realm
          name        : email
          certificate : ''
          email       : email
          givenName   : givenName
        url : registrationUrl()
        }))
      .then (response) ->
        return response

  return RegistrationApi
