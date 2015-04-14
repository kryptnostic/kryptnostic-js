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

require(['src/crypto-service-loader'],
    function(cryptoServiceLoader) {
        console.log(cryptoServiceLoader);
        cryptoServiceLoader.get("0ae1f7f8-495a-46c8-8f9e-48c1e12afcdc");
    });