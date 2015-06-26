'use strict';

//
// Demo script for testing library.
// All modules requried are loaded from the bulid soteria.js.
//

require(['require', 'src/utils', 'soteria.crypto-service-loader'], function(require) {
    var CryptoServiceLoader = require('soteria.crypto-service-loader');
    var SecurityUtils       = require('src/utils');

    var cryptoServiceLoader = new CryptoServiceLoader("demo");

    // set credentials
    sessionStorage.setItem('soteria.principal', 'krypt|demo');
    sessionStorage.setItem('soteria.credential', 'c1cc09e15a4529fcc50b57efde163dd2a9731d31be629fd9df4fd13bc70134f6');

    // get crypto service
    cryptoServiceLoader.getObjectCryptoService("8ee6d9af-9916-411d-9720-1f1a5a7f3a4c");
});
