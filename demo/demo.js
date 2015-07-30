'use strict';

//
// Demo script for testing library. Loads some kryptnosticObjects from the Kryptnostic backend as a smoke test of library functioanlity.
// All modules requried are loaded from the built kryptnostic.js, so require.js configuration is not necessary.
//

var renderObject = function (kryptnosticObject) {
  _.first(document.getElementsByClassName('kryptnostic-object')).innerHTML = JSON.stringify(kryptnosticObject,null,2);
};

require([
  'require',
  'bluebird',
  'kryptnostic.crypto-service-loader',
  'kryptnostic.storage-client',
  'kryptnostic.storage-request',
  'kryptnostic.permission-change-visitor',
  'kryptnostic.sharing-client',
  'kryptnostic.configuration',
  'kryptnostic.authentication-service',
  'kryptnostic.tree-loader',
  'kryptnostic.deletion-visitor'
], function(require) {

  var Promise                 = require('bluebird');
  var CryptoServiceLoader     = require('kryptnostic.crypto-service-loader');
  var StorageClient           = require('kryptnostic.storage-client');
  var StorageRequest          = require('kryptnostic.storage-request');
  var SharingClient           = require('kryptnostic.sharing-client');
  var Config                  = require('kryptnostic.configuration');
  var AuthenticationService   = require('kryptnostic.authentication-service');
  var TreeLoader              = require('kryptnostic.tree-loader');
  var DeletionVisitor         = require('kryptnostic.deletion-visitor');
  var PermissionChangeVisitor = require('kryptnostic.permission-change-visitor');

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
    var shareWithUsers = ['ryan'];
    storageClient.uploadObject(storageRequest)
    .then(function(objectId) {
      sharingClient.shareObject(objectId, shareWithUsers)
    });

    // change permissions on a whole tree of objects recursively
    var storageRequest = new StorageRequest({ body : 'this message will be shared' });
    var addVisitor     = new PermissionChangeVisitor(['demo','ryan']);
    var removeVisitor  = new PermissionChangeVisitor(['demo']);
    storageClient.uploadObject(storageRequest)
    .then(function(objectId) {
      treeLoader.load(objectId)
      .then (function(tree) {
        tree.visit(addVisitor)
        .then (function() {
          console.info('vistor changed: ', JSON.stringify(addVisitor.changedUsers));
          return tree.visit(removeVisitor)
          .then (function() {
            console.info('visitor changed: ', JSON.stringify(removeVisitor.changedUsers));
          });
        });
      })
    });

    // delete an object and all of its children recursively
    storageClient.getObjectIds()
    .then(function(ids) {
      return treeLoader.load(_.last(ids));
    })
    .then (function(tree) {
      tree.visit(new DeletionVisitor());
    });
  });
});
