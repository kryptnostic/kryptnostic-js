'use strict';

//
// Demo script for testing library. Loads some kryptnosticObjects from the Kryptnostic backend as a smoke test of library functioanlity.
// All modules requried are loaded from the built soteria.js, so require.js configuration is not necessary.
//

var renderObject = function (kryptnosticObject) {
  $(document).ready(function() {
    $('.kryptnostic-object').html(JSON.stringify(kryptnosticObject,null,2));
  });
};

require([
  'require',
  'bluebird',
  'soteria.crypto-service-loader',
  'soteria.storage-client',
  'soteria.storage-request',
  'soteria.sharing-client',
], function(require) {

  var Promise             = require('bluebird');
  var CryptoServiceLoader = require('soteria.crypto-service-loader');
  var StorageClient       = require('soteria.storage-client');
  var StorageRequest      = require('soteria.storage-request');
  var SharingClient       = require('soteria.sharing-client');

  var cryptoServiceLoader = new CryptoServiceLoader("demo");
  var storageClient       = new StorageClient();
  var sharingClient       = new SharingClient();

  // set credentials
  sessionStorage.setItem('soteria.principal', 'krypt|demo');
  sessionStorage.setItem('soteria.credential', 'c1cc09e15a4529fcc50b57efde163dd2a9731d31be629fd9df4fd13bc70134f6');

  // encrypt an object, upload, download, and decrypt
  var storageRequest = new StorageRequest({ body : 'test message' });
  storageClient.uploadObject(storageRequest)
  .then(function(objectId) {
    var loadPromises = {
      kryptnosticObject : storageClient.getObject(objectId),
      cryptoService     : cryptoServiceLoader.getObjectCryptoService(objectId)
    }

    Promise.props(loadPromises)
    .then(function(result) {
      var cryptoService     = result.cryptoService;
      var kryptnosticObject = result.kryptnosticObject;
      var decrypted         = kryptnosticObject.decrypt( cryptoService );
      renderObject(decrypted)
    })
  });

  // create an object and share it with another user
  var storageRequest = new StorageRequest({ body : 'this message will be shared' });
  var shareWithUsers = ['ryan']
  storageClient.uploadObject(storageRequest)
  .then(function(objectId) {
    sharingClient.shareObject(objectId, shareWithUsers)
  });
});
