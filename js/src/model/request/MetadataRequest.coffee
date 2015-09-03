define 'kryptnostic.metadata-request', [
  'require'
], (require) ->

  validateMetadata = (metadata) ->
    unless _.isArray(metadata)
      throw new Error 'must construct with a list of metadata'
    for metadatum in metadata
      unless metadatum.constructor.name is 'IndexedMetadata'
        throw new Error 'metadata list member must be indexed metadata'
  #
  # Http request model for encrypted search index metadata.
  # Author: rbuckheit
  #
  class MetadataRequest

    constructor: ({ @metadata }) ->
      @validate()

    validate : ->
      validateMetadata(@metadata)

  return MetadataRequest
