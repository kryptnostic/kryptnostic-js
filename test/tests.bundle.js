/*
 * entry point into the karma+webpack testing config. require all test files from the current directory and all
 * sub-directories to create the webpack testing context.
 *
 * https://github.com/webpack/karma-webpack#alternative-usage
 * http://webpack.github.io/docs/context.html#require-context
 */

// match all "*.test.js" files, except "KryptoEngine*.test.js" files
const testContext = require.context('.', true, /\/(?!KryptoEngine).*\.test\.js$/);
testContext.keys().forEach(testContext);
