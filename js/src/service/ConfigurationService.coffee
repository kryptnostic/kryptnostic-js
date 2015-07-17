define 'soteria.configuration', [
  'require'
  'lodash'
  'soteria.logger'
], (require) ->

  Logger = require 'soteria.logger'
  log    = Logger.get('ConfigurationService')

  DEFAULTS = {
    servicesUrl        : 'http://api.kryptnostic.com/v1'
    credentialProvider : 'soteria.credential-provider.local-storage'
  }

  #
  # Stores global soteria configuration.
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
