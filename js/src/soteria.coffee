#
# Pseudo-modile which includes all modules exported as part of the Soteria API.
# This file is for optimizer build purposes only and should not be required.
#

EXPORTED_MODULES = [
  'require'
  'lodash'
  'soteria.crypto-service-loader'
  'cs!KryptnosticObject'
  'cs!storage-client'
  'cs!ChunkingStrategyRegistry'
  'cs!DefaultChunkingStrategy'
]

define('soteria', EXPORTED_MODULES, (require) ->
  'use strict'
  return {}
)