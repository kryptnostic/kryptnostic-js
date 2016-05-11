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

const FILES = {
  KJS_ENTRY_POINT: path.join(__dirname, 'src/app.js')
};

const KJS_LIB_TARGET = 'umd';
const KJS_LIB_NAMESPACE = 'KJS';
const KJS_LIB_FILENAME = (NODE_ENV === PROD_ENV) ? 'kryptnostic.min.js' : 'kryptnostic.js';
const KJS_LIB_SOURCEMAP_FILENAME = `${KJS_LIB_FILENAME}.map`;

const PATHS = {
  DIST: path.join(__dirname, 'dist'),
  SOURCE: path.join(__dirname, 'src'),
  TEST: path.join(__dirname, 'test')
};

const KJS_BANNER = `
${pkg.name} - v${pkg.version}
${pkg.description}
${pkg.homepage}

Copyright (c) 2014-2016, Kryptnostic, Inc. All rights reserved.
`;

/*
 *
 * plugins
 *
 */

const kjsBannerPlugin = new webpack.BannerPlugin(
  KJS_BANNER,
  {
    entryOnly: true
  }
);

const kjsDefinePlugin = new webpack.DefinePlugin({
  __VERSION__: JSON.stringify(`v${pkg.version}`)
});

const kjsUglifyJsPlugin = new webpack.optimize.UglifyJsPlugin({
  sourceMap: true,
  compress: {
    screw_ie8: true,
    warnings: true
  }
});

function getPlugins() {

  const plugins = [
    kjsDefinePlugin,
    new webpack.NoErrorsPlugin()
  ];

  if (NODE_ENV === PROD_ENV) {
    plugins.push(kjsBannerPlugin);
    plugins.push(kjsUglifyJsPlugin);
  }

  return plugins;
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
    PATHS.SOURCE,
    PATHS.TEST
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
 * webpack config
 *
 */

const kjsWebpackConfig = {
  context: PATHS.SOURCE,
  entry: FILES.KJS_ENTRY_POINT,
  output: {
    path: PATHS.DIST,
    library: KJS_LIB_NAMESPACE,
    libraryTarget: KJS_LIB_TARGET,
    filename: KJS_LIB_FILENAME,
    sourceMapFilename: KJS_LIB_SOURCEMAP_FILENAME
  },
  module: {
    loaders: getLoaders().loaders,
    noParse: [
      /krypto\.js$/
    ]
  },
  resolve: {
    root: [
      PATHS.SOURCE,
      PATHS.TEST
    ],
    extensions: ['', '.js']
  },
  plugins: getPlugins(),
  bail: true
};

module.exports = kjsWebpackConfig;
