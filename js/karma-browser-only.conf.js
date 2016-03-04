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

    browsers: ['Firefox'],
    reporters: ['mocha'],

    frameworks: [
      'jasmine',
      'requirejs'
    ],

    files: [
      '../dist/kryptnostic.js',
      '../node_modules/sinon/pkg/sinon.js',
      'test/test-main.js',
      // { pattern: 'test/auth/SearchCredentialService-test.coffee', included: false },
      { pattern: 'test/engine/KryptnosticEngine-test.coffee',     included: false },
      { pattern: 'test/mocks/MockDataUtils.coffee',               included: false }
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
    },

    // we want TravisCI to actually open an instance of Chrome when running these tests
    customLaunchers: {
      FirefoxTravisCI: {
        base: 'Firefox'
      },
      ChromeTravisCI: {
        base: 'Chrome',
        flags: ['--no-sandbox']
      }
    }
  });

  // TravisCI integration when submitting a Pull Request to GitHub
  if (process.env.TRAVIS) {
    config.browsers = ['FirefoxTravisCI'];
  }
};
