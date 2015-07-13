define [
  'require'
  'soteria.configuration'
], (require) ->

  ConfigurationService = require 'soteria.configuration'

  EXPECTED_DEFAULTS = {
    servicesUrl        : 'http://localhost:8081/v1'
    credentialProvider : 'soteria.credential-provider.memory'
  }

  OVERRIDE_URL = 'http://localhost:9000/v1'

  describe 'ConfigurationService', ->

    describe 'initialization', ->

      it 'should initialize with a default services URL of localhost', ->
        expect(ConfigurationService.get('servicesUrl')).toBeDefined()
        expect(ConfigurationService.get('servicesUrl')).toBe(EXPECTED_DEFAULTS.servicesUrl)

    describe '#get', ->

      it 'should fetch whole config object if no key', ->
        ConfigurationService.set({servicesUrl : OVERRIDE_URL})
        expected = _.extend({}, EXPECTED_DEFAULTS, { servicesUrl : OVERRIDE_URL })
        expect(ConfigurationService.get()).toEqual(expected)

      it 'should fetch a single key if specified', ->
        ConfigurationService.set({someKey: 'someValue'})
        expect(ConfigurationService.get('someKey')).toBe('someValue')

    describe '#set', ->

      it 'should overwrite a default', ->
        ConfigurationService.set({servicesUrl : 'http://localhost:9000/v1'})
        expect(ConfigurationService.get('servicesUrl')).toBe('http://localhost:9000/v1')