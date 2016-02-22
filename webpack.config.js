/*
 * kryptnostic.js webpack config
 */
var pkg = require('./package.json');
var path = require('path');
var webpack = require('webpack');

/*
 *
 * constants
 *
 */

var FILES = {
  KJS_ENTRY_POINT: path.join(__dirname, 'src/app.js'),
  PACKAGE_JSON: path.join(__dirname, 'package.json')
};

var PATHS = {
  DIST: path.join(__dirname, 'dist'),
  SOURCE: path.join(__dirname, 'src'),
  TEST: path.join(__dirname, 'test')
};

var KJS_BANNER = `
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

var kjsBannerPlugin = new webpack.BannerPlugin(
  KJS_BANNER,
  {
    entryOnly: true
  }
);

var kjsUglifyJsPlugin = new webpack.optimize.UglifyJsPlugin({
  compress: {
    warnings: true
  }
});

var kjsDefinePlugin = new webpack.DefinePlugin({
  __VERSION__: JSON.stringify(`v${pkg.version}`)
});

/*
 *
 * config
 *
 */

module.exports = {
  entry: FILES.KJS_ENTRY_POINT,
  context: PATHS.SOURCE,
  output: {
    path: PATHS.DIST,
    library: 'KJS',
    libraryTarget: 'umd',
    filename: 'kryptnostic.js',
    sourceMapFilename: 'kryptnostic.js.map'
  },
  module: {
    loaders: [
      {
        loader: 'babel',
        test: /\.js$/,
        include: [
          PATHS.SOURCE,
          PATHS.TEST
        ]
      },
      {
        loader: 'exports',
        test: /krypto\.js/,
        exclude: [
          PATHS.SOURCE,
          PATHS.TEST
        ]
      }
    ],
    noParse: [
      /krypto\.js$/
    ]
  },
  resolve: {
    extensions: ['', '.js']
  },
  plugins: [
    kjsBannerPlugin,
    kjsDefinePlugin
  ],
  bail: true
};
