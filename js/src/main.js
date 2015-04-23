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

require(['require', 'cookies', 'src/utils', 'src/crypto-service-loader'], function(require) {
    var Cookies = require('cookies');
    var CryptoServiceLoader = require('src/crypto-service-loader'),
        SecurityUtils = require('src/utils');
    var cryptoServiceLoader = new CryptoServiceLoader("demo");

    // set auth cookies for e2e test
    Cookies.set(SecurityUtils.PRINCIPAL_COOKIE, 'krypt|vader');
    Cookies.set(SecurityUtils.CREDENTIAL_COOKIE, 'fd81f8a7af1cb138bdce93350768b2b453ccf238908091501b05fe25616168b0');
    // get crypto service
    cryptoServiceLoader.getObjectCryptoService("8ee6d9af-9916-411d-9720-1f1a5a7f3a4c");
});