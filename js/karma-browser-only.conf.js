// Karma configuration
// http://karma-runner.github.io/0.13/config/configuration-file.html

module.exports = function(config) {
  config.set({

    basePath: '.',
    port: 9876,
    colors: true,
    autoWatch: true,
    logLevel: config.LOG_ERROR,
    browserDisconnectTimeout: 60000,
    browserNoActivityTimeout: 60000,

    browsers: ['Chrome'],
    reporters: ['progress'],

    frameworks: [
      'jasmine',
      'jasmine-matchers',
      'requirejs'
    ],

    files: [
      '../dist/kryptnostic.js',
      'test/test-main.js',
      { pattern: 'test/engine/KryptnosticEngine-test.coffee', included: false },
      { pattern: 'test/mocks/MockDataUtils.coffee', included: false }
    ],

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
    }
  });
};
