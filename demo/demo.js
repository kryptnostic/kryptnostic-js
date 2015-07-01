'use strict';

//
// Demo script for testing library. Loads some kryptnosticObjects from the Kryptnostic backend as a smoke test of library functioanlity.
// All modules requried are loaded from the built soteria.js, so require.js configuration is not necessary.
//


var MAX_OBJECTS_TO_LOAD = 1;

require([
  'require',
  'soteria.crypto-service-loader',
  'soteria.storage-client',
  'soteria.storage-request'
], function(require) {

  var CryptoServiceLoader = require('soteria.crypto-service-loader');
  var StorageClient       = require('soteria.storage-client');
  var StorageRequest      = require('soteria.storage-request');

  var cryptoServiceLoader = new CryptoServiceLoader("demo");
  var storageClient       = new StorageClient();


  // set credentials
  sessionStorage.setItem('soteria.principal', 'krypt|demo');
  sessionStorage.setItem('soteria.credential', 'c1cc09e15a4529fcc50b57efde163dd2a9731d31be629fd9df4fd13bc70134f6');


  // upload an object
  var storageRequest = new StorageRequest({ body : 'test message' });

  storageClient.uploadObject(storageRequest)
  .done(function(result) {
    console.info('done uploadObject with result' + JSON.stringify(result))
  })

  // download objects
  storageClient.getObjectIds()
  .done(function(ids) {
    ids = _.takeRight(ids, MAX_OBJECTS_TO_LOAD);
    ids.forEach(function(id) {
      storageClient.getObject(id)
      .done(function(kryptnosticObject) {
        cryptoServiceLoader.getObjectCryptoService(id)
        .done(function (cryptoService) {
          kryptnosticObject = kryptnosticObject.decrypt(cryptoService)

          $(document).ready(function() {
            $('body').append("<div class='kryptnostic-object'>"
              + JSON.stringify(kryptnosticObject,null,2)
              + "</div>");
          });
        });
      });
    });
  });
});
