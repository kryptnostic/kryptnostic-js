define 'soteria.credential-provider-loader', [
  'require'
  'bluebird'
  'soteria.logger'
], (require) ->

  Promise = require 'bluebird'
  Logger  = require 'soteria.logger'

  log = Logger.get('CredentialProviderLoader')

  #
  # Loads credential providers dynamically by their module uri.
  # Author: rbuckheit
  #
  class CredentialProviderLoader

    @load : (uri) ->
      deferred = Promise.defer()

      require [ uri ], (providerClass) =>
        unless providerClass?
          deferred.reject('unknown credential provider uri ' + uri)
        else
          log.info('loaded credential provider', {uri})
          return deferred.resolve(providerClass)

      return deferred.promise
