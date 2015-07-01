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
  'cs!KryptnosticObject'
  'cs!StorageClient'
  'cs!ChunkingStrategyRegistry'
  'cs!DefaultChunkingStrategy'
  'cs!ObjectMetadata'
  'cs!StorageRequest'
  'cs!PendingObjectRequest'
]


define('soteria', EXPORTED_MODULES, (require) ->
  'use strict'
  return {}
)