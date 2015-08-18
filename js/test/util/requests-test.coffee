define [
  'require',
  'lodash',
  'kryptnostic.requests'
  'kryptnostic.credential-loader'
], (require) ->

  _        = require 'lodash'
  requests = require 'kryptnostic.requests'

  CREDENTIALS = { principal: '1111-2222-3333-4444', credential: 'password' }

  MOCK_REQUEST = {
    url     : 'http://www.google.com',
    method  : 'GET'
    headers : {}
  }

  describe 'requests', ->

    describe '#wrapCredentials', ->

      it 'should wrap explicitly passed credentials', ->
        wrapped = requests.wrapCredentials(MOCK_REQUEST, CREDENTIALS)

        expect(wrapped.headers).toEqual({
          'X-Kryptnostic-Principal'  : CREDENTIALS.principal
          'X-Kryptnostic-Credential' : CREDENTIALS.credential
        })

      it 'should wrap if no headers are provided', ->
        request = _.pick(MOCK_REQUEST, 'url', 'method')
        wrapped = requests.wrapCredentials(request, CREDENTIALS)

        expect(wrapped.headers).toEqual({
          'X-Kryptnostic-Principal'  : CREDENTIALS.principal
          'X-Kryptnostic-Credential' : CREDENTIALS.credential
        })
