/*
 * kryptnostic.js karma config
 *
 * http://karma-runner.github.io/0.13/config/configuration-file.html
 */

const getBaseKarmaConfig = require('./base.karma.config.js');

const BUILD_ENV = process.env.BUILD_ENV;
const TEST_ENV = 'TEST';

const FILES = {

  // match all test files: *.test.js, *.isotest.js
  ALL_TESTS: './**/*.?(iso)test.js',

  // match all test files that will run in a single bundle: webpack.testing.context.js
  BUNDLED_TESTS: './webpack.testing.context.js',

  // match all test files that must run in an individual (dedicated) bundle (KryptoEngine tests): *.isotest.js
  ISOLATED_TESTS: './**/*.isotest.js'
};

module.exports = function kjsKarmaConfig(theKarmaConfigObject) {

  const baseKarmaConfig = getBaseKarmaConfig(theKarmaConfigObject);

  /*
   * when we execute tests in a "TEST" environment, such as Travis CI or "npm test", we'll always run all of the tests,
   * never an individual test. in this case, we can have a more performant configuration by having webpack generate a
   * single bundle that contains all test files, instead of a distinct bundle for each test file.
   *
   * the exception to this is any test file that is testing KryptoEngine. since KryptoEngine is a singleton, tests will
   * break when multiple files need to initialize KryptoEngine. as such, any test file that needs its own instance of
   * KryptoEngine will have to be bundled seperately.
   */
  if (BUILD_ENV === TEST_ENV) {
    baseKarmaConfig.files.push(
      { pattern: FILES.ISOLATED_TESTS, included: true, watched: false },
      { pattern: FILES.BUNDLED_TESTS, included: true, watched: false }
    );
  }
  else {
    baseKarmaConfig.files.push(
      { pattern: FILES.ALL_TESTS, included: true, watched: false }
    );
  }

  if (BUILD_ENV === TEST_ENV) {
    baseKarmaConfig.preprocessors[FILES.ISOLATED_TESTS] = ['webpack'];
    baseKarmaConfig.preprocessors[FILES.BUNDLED_TESTS] = ['webpack'];
  }
  else {
    baseKarmaConfig.preprocessors[FILES.ALL_TESTS] = ['webpack'];
  }

  theKarmaConfigObject.set(baseKarmaConfig);
};
