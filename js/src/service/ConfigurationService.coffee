define 'kryptnostic.configuration', [
  'require'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'
  log    = Logger.get('ConfigurationService')

  DEFAULTS = {
    servicesUrl        : 'http://api.kryptnostic.com/v1'
    servicesUrlV2      : 'http://api.kryptnostic.com/v2'
    heraclesUrl        : 'https://api.kryptnostic.com/heracles/v1'
    heraclesUrlV2      : 'https://api.kryptnostic.com/heracles/v2'
    credentialProvider : 'kryptnostic.credential-provider.local-storage'
    cachingProvider    : 'kryptnostic.caching-provider.jscache'
  }

  #
  # Stores global kryptnostic configuration.
  # Author: rbuckheit
  #
  class ConfigurationService

    @config : _.cloneDeep(DEFAULTS)

    @set : (opts) ->
      _.extend(ConfigurationService.config, opts)
      log.info('configuration was updated', @config)

    @get : (key) ->
      if key?
        return ConfigurationService.config[key]
      else
        return ConfigurationService.config

  return ConfigurationService
