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
  'soteria.configuration',
  'soteria.authentication-service',
  'soteria.tree-loader',
  'soteria.deletion-visitor'
], function(require) {

  var Promise               = require('bluebird');
  var CryptoServiceLoader   = require('soteria.crypto-service-loader');
  var StorageClient         = require('soteria.storage-client');
  var StorageRequest        = require('soteria.storage-request');
  var SharingClient         = require('soteria.sharing-client');
  var Config                = require('soteria.configuration');
  var AuthenticationService = require('soteria.authentication-service');
  var TreeLoader            = require('soteria.tree-loader');
  var DeletionVisitor       = require('soteria.deletion-visitor');

  var cryptoServiceLoader = new CryptoServiceLoader();
  var storageClient       = new StorageClient();
  var sharingClient       = new SharingClient();
  var treeLoader          = new TreeLoader();

  // configure the client
  Config.set({
    servicesUrl        : 'http://localhost:8081/v1',
  });

  // authenticate the user
  AuthenticationService.authenticate({
    username : 'demo',
    password : 'demo',
    realm    : 'krypt'
  }).then(function(){

    // encrypt an object, upload it, download it, and decrypt it.
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
      .then(function() {
        storageClient.deleteObject(objectId);
      })
    });

    // create an object and share it with another user
    var storageRequest = new StorageRequest({ body : 'this message will be shared' });
    var shareWithUsers = ['ryan']
    storageClient.uploadObject(storageRequest)
    .then(function(objectId) {
      sharingClient.shareObject(objectId, shareWithUsers)
    });

    // delete an object and all of its children resursively
    storageClient.getObjectIds()
    .then(function(ids) {
      return treeLoader.load(_.last(ids));
    })
    .then (function(tree) {
      tree.visit(new DeletionVisitor());
    });
  });
});
