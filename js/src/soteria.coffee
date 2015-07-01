
#
# Pseudo-modile which includes all modules exported as part of soteria.
# This file is for optimizer build purposes only and should not be required or edited.
#

EXPORTED_MODULES = [
  # library
  # =======
  'cookies'
  'forge.min'
  'jquery'
  'lodash'
  'pako'
  'require'
  'revalidator'

  # soteria
  # =======
  'soteria.crypto-service-loader'
  'soteria.cypher'
  'cs!ChunkingStrategyRegistry'
  'cs!DefaultChunkingStrategy'
  'cs!StorageClient'
  'cs!http/ObjectApi'
  'cs!model/object/KryptnosticObject'
  'cs!model/object/ObjectMetadata'
  'cs!model/request/PendingObjectRequest'
  'cs!model/request/StorageRequest'
  'cs!model/schema/kryptnostic-object'
  'cs!model/schema/object-metadata'
  'cs!model/schema/pending-object-request'
  'cs!model/schema/storage-request'
  'cs!model/schema/validator'
]


define('soteria', EXPORTED_MODULES, (require) ->
  'use strict'
  return {}
)
