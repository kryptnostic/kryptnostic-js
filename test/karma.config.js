/*
 * kryptnostic.js karma config
 *
 * http://karma-runner.github.io/0.13/config/configuration-file.html
 */

const TEST_ENV = 'TEST';
const NODE_ENV = process.env.NODE_ENV;

const FILES = {

  // match all test files: *.test.js, *.isotest.js
  ALL_TESTS: './**/*\.?(iso)test\.js',

  // match all test files that will run in a single bundle: webpack.testing.context.js
  BUNDLED_TESTS: './webpack.testing.context.js',

  // match all test files that must run in an individual (dedicated) bundle (KryptoEngine tests): *.isotest.js
  ISOLATED_TESTS: './**/*\.isotest\.js'
};

const BABEL_LOADER = {
  loader: 'babel',
  test: /\.js?$/,
  exclude: [
    /node_modules/,
    /krypto\.js$/
  ],
  query: {
    cacheDirectory: true
  }
};

module.exports = function kjsKarmaConfig(config) {

  /*
   * when we execute tests in a "TEST" environment, such as Travis CI or "npm test", we'll always run all of the tests,
   * never an individual test. in this case, we can have a more performant configuration by having webpack generate a
   * single bundle that contains all test files, instead of a distinct bundle for each test file.
   *
   * the exception to this is any test file that is testing KryptoEngine. since KryptoEngine is a singleton, tests will
   * break when multiple files need to initialize KryptoEngine. as such, any test file that needs its own instance of
   * KryptoEngine will have to be bundled seperately.
   */
  const testFiles = [];
  if (NODE_ENV === TEST_ENV) {
    testFiles.push(
      { pattern: FILES.ISOLATED_TESTS, included: true, watched: false },
      { pattern: FILES.BUNDLED_TESTS, included: true, watched: false }
    );
  }
  else {
    testFiles.push(
      { pattern: FILES.ALL_TESTS, included: true, watched: false }
    );
  }

  const filePreProcessors = {};
  if (NODE_ENV === TEST_ENV) {
    filePreProcessors[FILES.ISOLATED_TESTS] = ['webpack'];
    filePreProcessors[FILES.BUNDLED_TESTS] = ['webpack'];
  }
  else {
    filePreProcessors[FILES.ALL_TESTS] = ['webpack'];
  }

  config.set({

    // root path that will be used to resolve all relative paths defined in "files" and "exclude"
    basePath: '.',

    /*
     * a list of files to load in the browser
     *
     * http://karma-runner.github.io/0.13/config/files.html
     */
    files: testFiles,

    // a list of files to exclude from the matching files specified in the "files" config
    exclude: [],

    /*
     * a list of browsers to launch and capture
     *
     * http://karma-runner.github.io/0.13/config/browsers.html
     * https://npmjs.org/browse/keyword/karma-launcher
     */
    browsers: [
      'PhantomJS'
    ],

    /*
     * a list of test frameworks to use
     *
     * https://npmjs.org/browse/keyword/karma-adapter
     */
    frameworks: [
      'jasmine'
    ],

    /*
     * a list of reporters to use for test results
     *
     * https://npmjs.org/browse/keyword/karma-reporter
     */
    reporters: [
      'spec', // karma-spec-reporter
      'jasmine-diff' // karma-jasmine-diff-reporter
    ],

    /*
     * configuration for karma-spec-reporter
     * https://github.com/mlex/karma-spec-reporter
     */
    specReporter: {
      showSpecTiming: true,
      suppressSkipped: true // don't print information about skipped tests
    },

    /*
     * the keys in the "preprocessors" config filter the matching files specified in the "files" config for processing
     * before serving them to the browser
     *
     * http://karma-runner.github.io/0.13/config/preprocessors.html
     * https://npmjs.org/browse/keyword/karma-preprocessor
     */
    preprocessors: filePreProcessors,

    /*
     * https://github.com/webpack/karma-webpack
     */
    webpack: {
      // https://webpack.github.io/docs/configuration.html#node
      node: {
        fs: 'empty'
      },
      cache: true,
      module: {
        loaders: [
          BABEL_LOADER
        ]
      }
    },

    /*
     * https://webpack.github.io/docs/webpack-dev-middleware.html
     */
    webpackMiddleware: {
      noInfo: true
    },

    /*
     * enables or disables watching files so to execute the tests whenever a file changes
     */
    autoWatch: false,

    /*
     * continuous integration mode
     * if true, Karma will start and capture all configured browsers, run the tests, and then exit with an exit code of
     * 0 or 1; 0 if all tests passed, 1 if any tests failed
     */
    singleRun: true,

    /*
     * possible values:
     *   config.LOG_DISABLE
     *   config.LOG_ERROR
     *   config.LOG_WARN
     *   config.LOG_INFO
     *   config.LOG_DEBUG
     */
    logLevel: config.LOG_DEBUG
  });
};
