define 'kryptnostic.registration-api', [
  'require'
  'axios'
  'bluebird'
  'kryptnostic.configuration'
], (require) ->

  axios         = require 'axios'
  Promise       = require 'bluebird'
  Configuration = require 'kryptnostic.configuration'

  registrationUrl = -> Configuration.get('heraclesUrlV2') + '/registration/user'


  DEFAULT_HEADERS = { 'Content-Type' : 'application/json' }

  #
  # HTTP calls for registration.
  #
  class RegistrationApi

    register: (userRegistrationRequest) ->
      Promise.resolve()
      .then ->
        userRegistrationRequest.validate()
      .then ->
        axios({
          method  : 'POST'
          data    : JSON.stringify(userRegistrationRequest)
          url     : registrationUrl()
          headers : _.clone(DEFAULT_HEADERS)
        })
      .then (response) ->
        return response.data

  return RegistrationApi
