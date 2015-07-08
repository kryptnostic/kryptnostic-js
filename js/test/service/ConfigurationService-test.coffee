define [
  'require'
  'soteria.configuration'
], (require) ->

  ConfigurationService = require 'soteria.configuration'

  OVERRIDE_URL = 'http://localhost:9000/v1'
  DEFAULT_URL  = 'http://localhost:8081/v1'

  describe 'ConfigurationService', ->

    describe 'initialization', ->

      it 'should initialize with a default services URL of localhost', ->
        expect(ConfigurationService.get('servicesUrl')).toBeDefined()
        expect(ConfigurationService.get('servicesUrl')).toBe(DEFAULT_URL)

    describe '#get', ->

      it 'should fetch whole config object if no key', ->
        ConfigurationService.set({servicesUrl : OVERRIDE_URL})
        expect(ConfigurationService.get()).toEqual({ servicesUrl : OVERRIDE_URL })

      it 'should fetch a single key if specified', ->
        ConfigurationService.set({someKey: 'someValue'})
        expect(ConfigurationService.get('someKey')).toBe('someValue')

    describe '#set', ->

      it 'should overwrite a default', ->
        ConfigurationService.set({servicesUrl : 'http://localhost:9000/v1'})
        expect(ConfigurationService.get('servicesUrl')).toBe('http://localhost:9000/v1')
