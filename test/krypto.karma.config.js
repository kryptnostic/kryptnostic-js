/*
 * krypto.js karma config
 *
 * http://karma-runner.github.io/0.13/config/configuration-file.html
 */

const getBaseKarmaConfig = require('./base.karma.config.js');
const webpack = require('webpack');

const FILES = {
  KRYPTO_TESTS: './**/Krypto.test.js'
};

const UGLIFYJS_PLUGIN = new webpack.optimize.UglifyJsPlugin({
  compress: {
    screw_ie8: true,
    unused: false,
    warnings: false
  },
  mangle: false,
  sourceMap: false
});

module.exports = function kryptoKarmaConfig(theKarmaConfigObject) {

  const baseKarmaConfig = getBaseKarmaConfig(theKarmaConfigObject);

  baseKarmaConfig.files.push(
    { pattern: FILES.KRYPTO_TESTS, included: true, watched: false }
  );

  baseKarmaConfig.preprocessors[FILES.KRYPTO_TESTS] = ['webpack'];

  baseKarmaConfig.webpack.plugins.push(
    UGLIFYJS_PLUGIN
  );

  theKarmaConfigObject.set(baseKarmaConfig);
};
