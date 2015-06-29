define('soteria.storage-client', [
  'require'
  'jquery'
  'soteria.security-utils'
  'soteria.kryptnostic-object'
], (require) ->
  'use strict'

  jquery            = require 'jquery'
  SecurityUtils     = require 'soteria.security-utils'
  KryptnosticObject = require 'soteria.kryptnostic-object'

  # TODO: define a configurable URL provider.
  OBJECT_URL    = 'http://localhost:8081/v1/object'

  #
  # Client for listing and loading Kryptnostic encrypted objects.
  # Author: rbuckheit
  #
  class StorageClient

    getObjectIds : (id) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL,
        type : 'GET'
      }))
      .then (data) ->
        return data.data

    getObject : (id) ->
      jquery.ajax(SecurityUtils.wrapRequest({
        url  : OBJECT_URL + '/' + id,
        type : 'GET'
      }))
      .then (data) ->
        return new KryptnosticObject(data);

  return StorageClient
)
