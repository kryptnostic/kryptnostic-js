#
# Pseudo-modile which includes all modules exported as part of the Soteria API.
# This file is for optimizer build purposes only and should not be required.
#

EXPORTED_MODULES = [
  # library
  # =======
  'require'
  'lodash'
  'revalidator'

  # soteria
  # =======
  'soteria.crypto-service-loader'
  'soteria.cypher'
  'cs!StorageClient'
  'cs!ChunkingStrategyRegistry'
  'cs!DefaultChunkingStrategy'
  'cs!model/request/StorageRequest'
  'cs!model/request/PendingObjectRequest'
  'cs!model/schema/storage-request'
  'cs!model/schema/pending-object-request'
  'cs!model/schema/kryptnostic-object'
  'cs!model/schema/object-metadata'
  'cs!model/object/KryptnosticObject'
  'cs!model/object/ObjectMetadata'
  'cs!model/schema/validator'
  'cs!http/ObjectApi'
]


define('soteria', EXPORTED_MODULES, (require) ->
  'use strict'
  return {}
)