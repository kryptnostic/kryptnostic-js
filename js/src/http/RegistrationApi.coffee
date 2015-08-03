define 'kryptnostic.registration-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
], (require) ->

  axios         = require 'axios'
  Configuration = require 'kryptnostic.configuration'

  registrationUrl = -> Configuration.get('heraclesUrl') + '/registration/developers'

  #
  # HTTP calls for registration.
  #
  class RegistrationApi

    register: ({ realm, username, name }) ->
      Promise.resolve(axios({
        method : 'POST'
        data : {
          realm       : realm,
          name        : username,
          email       : username,
          givenName   : name,
          certificate : ''
        }
        url : registrationUrl()
      }))
      .then (response) ->
        return response

  return RegistrationApi
