define 'soteria.deflating-marshaller', [
  'require'
  'pako'
  'forge'
  'lodash'
], (require) ->

  Pako  = require 'pako'
  Forge = require 'forge'
  _     = require 'lodash'

  EMPTY_BUFFER       = ''
  INTEGER_BYTE_COUNT = 4

  countBytes = (data) ->
    return Forge.util.createBuffer(data, 'raw').length()

  validateBytes = (data) ->
    unless _.isString(data)
      throw new Error 'input data must be in string form'

  #
  # Compresses data into a custom binary representation of the form:
  #
  # | <length> | <compressed_data> |
  #
  # length          : an integer (32 bytes) containing the UNCOMPRESSED length
  # compressed_data : the data after compression.
  #
  # The length field is used for verification purposes, and will be checked
  # against the length of the decompressed payload when unmarshalling.
  #
  # Author: rbuckheit
  #
  class DeflatingMarshaller

    # deflate and marshall uncompressed data into binary format
    marshall: (bytes) ->
      validateBytes(bytes)

      uncompressedLength = countBytes(bytes)
      compressedBytes    = Pako.deflate(bytes, {to: 'string'})
      buffer             = Forge.util.createBuffer(EMPTY_BUFFER, 'raw')

      buffer.putInt32(uncompressedLength)
      buffer.putBytes(compressedBytes)

      return buffer.data

    # unmarshall and inflate compressed data from binary format
    unmarshall: (bytes) ->
      validateBytes(bytes)

      buffer          = Forge.util.createBuffer(bytes, 'raw')
      verifyLength    = buffer.getInt32(INTEGER_BYTE_COUNT)
      compressedBytes = buffer.getBytes(buffer.length())
      inflatedBytes   = Pako.inflate(compressedBytes, {to: 'string'})
      inflatedLength  = countBytes(inflatedBytes)

      if verifyLength isnt inflatedLength
        throw new Error 'verifying byte count failed'

      return inflatedBytes

  return DeflatingMarshaller
