var allTestFiles   = [];
var TEST_REGEXP    = /(.*)(spec|test)\.js$/i;
var SOTERIA_REGEXP = /soteria.js/;

var pathToModule = function(path) {
    return path.replace(/^\/base\//, '').replace(/\.js$/, '');
};

Object.keys(window.__karma__.files).forEach(function(file) {
    if (TEST_REGEXP.test(file)) {
        // Normalize paths to RequireJS module names.
        console.info('found TEST: ' + file);
        allTestFiles.push(pathToModule(file));
    }
    if (SOTERIA_REGEXP.test(file)) {
        console.info('found BUILD: ' + file);
        allTestFiles.push(file);
    }
});

require.config({
    // Karma serves files under /base, which is the basePath from your config file
    baseUrl: '/base/lib',

    paths: {
        src   : '../src',
        test  : '../test'
    },

    // dynamically load all test files
    deps : allTestFiles,

    // we have to kickoff jasmine, as it is asynchronous
    callback: window.__karma__.start
});