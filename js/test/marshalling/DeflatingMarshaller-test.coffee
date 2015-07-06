define [
  'require'
  'soteria.deflating-marshaller'
], (require) ->

  DeflatingMarshaller = require 'soteria.deflating-marshaller'

  TEST_STRING          = 'testing deflate string'

  describe 'DeflatingMarshaller', ->

    it 'should marshall and unmarshall', ->
      marshalled = new DeflatingMarshaller().marshall(TEST_STRING)
      unmarshalled = new DeflatingMarshaller().unmarshall(marshalled)
      expect(unmarshalled).toEqual(TEST_STRING)

    it 'should throw if input data is not a string', ->
      marshaller = new DeflatingMarshaller()
      expect( -> marshaller.unmarshall(1234) ).toThrow()
      expect( -> marshaller.marshall(1234) ).toThrow()
