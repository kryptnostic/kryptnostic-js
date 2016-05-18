/*
 * a shared karma config with default configurations
 */

const webpack = require('webpack');

/*
 *
 * webpack loaders
 *
 */

const BABEL_LOADER = {
  loader: 'babel',
  test: /\.js$/,
  exclude: [
    /node_modules/,
    /krypto\.js$/
  ],
  query: {
    cacheDirectory: true
  }
};

/*
 * workaround to address webpack 2 throwing errors: https://github.com/webpack/node-libs-browser/issues/19
 */
const JSON_LOADER = {
  loader: 'json',
  test: /\.json$/,
  include: [
    /node_modules/
  ],
  exclude: [
    /krypto\.js$/
  ]
};

/*
 *
 * webpack plugins
 *
 */

const PROGRESS_PLUGIN = new webpack.ProgressPlugin();

module.exports = function getBaseKarmaConfig(theKarmaConfigObject) {

  return {

    // root path that will be used to resolve all relative paths defined in "files" and "exclude"
    basePath: '.',

    /*
     * a list of files to load in the browser
     *
     * http://karma-runner.github.io/0.13/config/files.html
     */
    files: [],

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
    preprocessors: {},

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
          BABEL_LOADER,
          JSON_LOADER
        ]
      },
      plugins: [
        PROGRESS_PLUGIN
      ]
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
     * the amount of time (in ms) Karma will wait for a message from a browser before disconnecting from it
     */
    browserNoActivityTimeout: 60000, // 60s

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
    logLevel: theKarmaConfigObject.LOG_DEBUG
  };
};
