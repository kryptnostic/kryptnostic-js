/*
 * kryptnostic.js karma config
 *
 * http://karma-runner.github.io/0.13/config/configuration-file.html
 */

const TEST_ENV = 'TEST';
const NODE_ENV = process.env.NODE_ENV;

const FILES = {
  ALL_TESTS: './**/*\.test\.js',
  BUNDLED_TESTS: './tests.bundle.js'
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
   */
  const testFiles = [];
  if (NODE_ENV === TEST_ENV) {
    testFiles.push(
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
