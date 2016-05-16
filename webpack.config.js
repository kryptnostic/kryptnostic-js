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

// process.env.NODE_ENV is expected to be defined externally (see package.json)
const NODE_ENV = process.env.NODE_ENV;
const PROD_ENV = 'PROD';

const DIRECTORY_PATHS = {
  DIST: path.join(__dirname, 'dist'),
  SOURCE: path.join(__dirname, 'src'),
  TEST: path.join(__dirname, 'test')
};

const FILE_PATHS = {
  BUILD_ENTRY_POINT: path.join(__dirname, 'src/app.js')
};

const FILE_REGEXES = {
  FORGE_JS: /forge.*\.js$/,
  KJS: /kryptnostic.*\.js$/,
  KRYPTO_JS: /krypto\.js$/
};

const KJS_LIB_TARGET = 'umd';
const KJS_LIB_NAMESPACE = 'KJS';
const KJS_LIB_FILENAME = (NODE_ENV === PROD_ENV) ? 'kryptnostic.min.js' : 'kryptnostic.js';
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

const kjsBannerPlugin = new webpack.BannerPlugin(
  KJS_BANNER,
  {
    entryOnly: true,
    include: [
      FILE_REGEXES.KJS
    ]
  }
);

const kjsDefinePlugin = new webpack.DefinePlugin({
  __VERSION__: JSON.stringify(`v${pkg.version}`)
});

const kjsUglifyJsPlugin = new webpack.optimize.UglifyJsPlugin({
  sourceMap: false,
  compress: {
    screw_ie8: true,
    unused: false,
    warnings: false
  },
  comments: false,
  mangle: false
});

function getPlugins() {

  const plugins = [
    new webpack.NoErrorsPlugin()
  ];

  plugins.push(kjsDefinePlugin);

  if (NODE_ENV === PROD_ENV) {
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
  resolve: {
    alias: getAliases(),
    extensions: ['', '.js'],
    root: [
      DIRECTORY_PATHS.SOURCE,
      DIRECTORY_PATHS.TEST
    ]
  },
  plugins: getPlugins(),
  bail: true
};

module.exports = kjsWebpackConfig;
