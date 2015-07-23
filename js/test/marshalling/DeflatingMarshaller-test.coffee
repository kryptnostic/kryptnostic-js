define [
  'require'
  'kryptnostic.deflating-marshaller'
], (require) ->

  DeflatingMarshaller = require 'kryptnostic.deflating-marshaller'

  TEST_DATA_1            = 'testing deflate string'
  TEST_DATA_1_MARSHALLED = 'AAAAFnicK0ktLsnMS1dISU3LSSxJVSguKQJyAWQWCKs='
  TEST_DATA_2            = 'testing another string'

  describe 'DeflatingMarshaller', ->

    it 'should marshall an object', ->
      marshalled = new DeflatingMarshaller().marshall(TEST_DATA_1)
      expect(btoa(marshalled)).toEqual(TEST_DATA_1_MARSHALLED)

    it 'should unmarshall an object', ->
      unmarshalled = new DeflatingMarshaller().unmarshall(atob(TEST_DATA_1_MARSHALLED))
      expect(unmarshalled).toEqual(TEST_DATA_1)

    it 'should marshall and unmarshall yielding same result', ->
      marshalled   = new DeflatingMarshaller().marshall(TEST_DATA_2)
      unmarshalled = new DeflatingMarshaller().unmarshall(marshalled)
      expect(unmarshalled).toEqual(TEST_DATA_2)

    it 'should throw if input data is not a string', ->
      marshaller = new DeflatingMarshaller()
      expect( -> marshaller.unmarshall(1234) ).toThrow()
      expect( -> marshaller.marshall(1234) ).toThrow()
