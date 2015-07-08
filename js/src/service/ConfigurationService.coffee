define 'soteria.configuration', [
  'require'
  'lodash'
  'soteria.logger'
], (require) ->

  log = require 'soteria.logger'

  DEFAULTS = {
    servicesUrl : 'http://localhost:8081/v1'
  }

  #
  # Stores global Soteria configuration.
  # Author: rbuckheit
  #

  class ConfigurationService

    @config : _.cloneDeep(DEFAULTS)

    @set : (opts) ->
      _.extend(ConfigurationService.config, opts)

    @get : (key) ->
      if key?
        return ConfigurationService.config[key]
      else
        return ConfigurationService.config

  return ConfigurationService
