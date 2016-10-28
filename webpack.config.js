/*
 * kryptnostic.js webpack config
 */
const pkg = require('./package.json');
const path = require('path');
const webpack = require('webpack');

/*
 *
 * constants
 *
 */

// process.env.BUILD_ENV is expected to be defined externally (see package.json)
const BUILD_ENV = process.env.BUILD_ENV;
const PROD_ENV = 'PROD';

const DIRECTORY_PATHS = {
  DIST: path.join(__dirname, 'dist'),
  NODE: path.join(__dirname, 'node_modules'),
  SOURCE: path.join(__dirname, 'src'),
  TEST: path.join(__dirname, 'test')
};

const FILE_NAMES = {
  FORGE_JS: 'forge.min.js',
  KRYPTO_JS: 'krypto.js'
};

const FILE_PATHS = {
  FORGE_JS: `${DIRECTORY_PATHS.NODE}/node-forge/js/${FILE_NAMES.FORGE_JS}`,
  KRYPTO_JS: `${DIRECTORY_PATHS.NODE}/krypto-js/${FILE_NAMES.KRYPTO_JS}`,
  BUILD_ENTRY_POINT: `${DIRECTORY_PATHS.SOURCE}/playground.js`
};

const FILE_REGEXES = {
  FORGE_JS: /forge.*\.js$/,
  KJS: /kryptnostic.*\.js$/,
  KRYPTO_JS: /krypto\.js$/
};

const KJS_LIB_TARGET = 'umd';
const KJS_LIB_NAMESPACE = 'KJS';
const KJS_LIB_FILENAME = (BUILD_ENV === PROD_ENV) ? 'kryptnostic.min.js' : 'kryptnostic.js';
const KJS_LIB_SOURCEMAP_FILENAME = `${KJS_LIB_FILENAME}.map`;

const KJS_BANNER = `
${pkg.name} - v${pkg.version}
${pkg.description}
${pkg.homepage}

Copyright (c) 2014-2016, Kryptnostic, Inc. All rights reserved.
`;

/*
 *
 * aliases
 *
 */

function getAliases() {

  return {
    forge: FILE_PATHS.FORGE_JS
  };
}

/*
 *
 * loaders
 *
 */

const BABEL_LOADER = {
  loader: 'babel',
  test: /\.js$/,
  include: [
    DIRECTORY_PATHS.SOURCE,
    DIRECTORY_PATHS.TEST
  ]
};

function getLoaders() {

  const loaders = [
    BABEL_LOADER
  ];

  const preLoaders = [];
  const postLoaders = [];

  return {
    loaders,
    preLoaders,
    postLoaders
  };
}

/*
 *
 * plugins
 *
 */

const kjsBannerPlugin = new webpack.BannerPlugin({
  banner: KJS_BANNER,
  entryOnly: true,
  include: [
    FILE_REGEXES.KJS
  ]
});

const kjsDefinePlugin = new webpack.DefinePlugin({
  __VERSION__: JSON.stringify(`v${pkg.version}`)
});

const kjsProvidePlugin = new webpack.ProvidePlugin({
  _: 'lodash'
});

const kjsUglifyJsPlugin = new webpack.optimize.UglifyJsPlugin({
  compress: {
    screw_ie8: true,
    unused: false,
    warnings: false
  },
  comments: false,
  mangle: false,
  sourceMap: false
});

function getPlugins() {

  const plugins = [
    new webpack.NoErrorsPlugin()
  ];

  plugins.push(kjsDefinePlugin);
  // plugins.push(kjsProvidePlugin);

  if (BUILD_ENV === PROD_ENV) {
    plugins.push(kjsUglifyJsPlugin);
  }

  // the BannerPlugin comes last to avoid being removed by UglifyJs
  plugins.push(kjsBannerPlugin);

  return plugins;
}

/*
 *
 * webpack config
 *
 */

const kjsWebpackConfig = {
  bail: true,
  cache: false,
  context: DIRECTORY_PATHS.SOURCE,
  entry: FILE_PATHS.BUILD_ENTRY_POINT,
  output: {
    path: DIRECTORY_PATHS.DIST,
    library: KJS_LIB_NAMESPACE,
    libraryTarget: KJS_LIB_TARGET,
    filename: KJS_LIB_FILENAME,
    sourceMapFilename: KJS_LIB_SOURCEMAP_FILENAME
  },
  module: {
    loaders: getLoaders().loaders,
    noParse: [
      FILE_REGEXES.FORGE_JS,
      FILE_REGEXES.KRYPTO_JS
    ]
  },
  plugins: getPlugins(),
  resolve: {
    alias: getAliases(),
    extensions: ['', '.js'],
    modules: [
      // order matters
      DIRECTORY_PATHS.SOURCE,
      'node_modules'
    ]
  },
  worker: {
    output: {
      filename: '[hash].worker.js'
    }
  }
};

module.exports = kjsWebpackConfig;
