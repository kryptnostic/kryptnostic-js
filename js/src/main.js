'use strict';

require.config({
    //By default load any module IDs from js/lib
    baseUrl: 'js/lib',
    //except, if the module ID starts with "app",
    //load it from the js/app directory. paths
    //config is relative to the baseUrl, and
    //never includes a ".js" extension since
    //the paths config could be for a directory.
    paths: {
        src: '../src'
    }
});

require(['require','src/crypto-service-loader'], function(require) {
        var CryptoServiceLoader = require('src/crypto-service-loader');
        var cryptoServiceLoader = new CryptoServiceLoader();
        cryptoServiceLoader.get("8ee6d9af-9916-411d-9720-1f1a5a7f3a4c");
    });