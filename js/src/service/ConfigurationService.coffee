define 'kryptnostic.configuration', [
  'require'
  'lodash'
  'kryptnostic.logger'
], (require) ->

  Logger = require 'kryptnostic.logger'
  log    = Logger.get('ConfigurationService')

  DEFAULTS = {
    servicesUrl        : 'http://api.kryptnostic.com/v1'
    heraclesUrl        : 'https://api.kryptnostic.com/heracles/v1'
    credentialProvider : 'kryptnostic.credential-provider.session-storage'
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
