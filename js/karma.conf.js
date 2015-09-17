// Karma configuration
// http://karma-runner.github.io/0.13/config/configuration-file.html

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '.',

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,

    // how long Karma should wait for a browser to reconnect
    browserDisconnectTimeout: 60000,

    // how long Karma should wait for a message from a browser before disconnecting from it
    browserNoActivityTimeout: 60000,

    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: [
      'jasmine',
      'requirejs'
    ],

    // list of files / patterns to load in the browser
    // by default, a script tag will be created for the files, unless you use the "included: false" option
    files: [
      '../dist/kryptnostic.js',
      '../node_modules/sinon/pkg/sinon.js',
      'test/test-main.js',
      { pattern: 'test/**/*.js',     included: false },
      { pattern: 'test/**/*.coffee', included: false }
    ],

    // list of files to exclude
    exclude: [
      'test/auth/SearchCredentialService-test.coffee',
      'test/engine/KryptnosticEngine-test.coffee',
      'test/search/MetadataMapper-test.coffee'
    ],

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      '**/*.coffee': ['coffee']
    },

    coffeePreprocessor: {
      options: {
        bare      : false,
        sourceMap : false
      },
      transformPath: function(path) {
        return path.replace(/\.coffee$/, '.js');
      }
    },

    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],

    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_ERROR,

    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS']
  });
};
