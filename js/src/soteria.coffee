# Pseudo-modile which includes all modules exported as part of the Soteria API.

EXPORTED_MODULES = [
  'require'
  'soteria.crypto-service-loader'
]

define('soteria', EXPORTED_MODULES, (require) ->
  'use strict'
)